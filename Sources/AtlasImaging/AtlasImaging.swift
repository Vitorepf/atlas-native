import Foundation
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers
import AtlasCore

// Rich Input · L3 — normalização de imagem COMPARTILHADA iOS+macOS.
// ImageIO/CoreGraphics existem nas duas plataformas — até a compressão é
// código único, não espelho (a lição do gap RN: mobile subia bytes crus).
//
// Regras (espelham o imageProcessor do desktop, com desvios documentados):
//   - HEIC→JPEG OBRIGATÓRIO: o servidor re-sniffa MIME via getimagesize e
//     rejeita HEIC com 422. Foto de iPhone SEMPRE passa por aqui.
//   - resize lado maior → 2048px (kCGImageSourceThumbnailMaxPixelSize, com
//     transform de orientação EXIF — foto deitada não chega girada).
//   - JPEG q0.86; PNG com alpha PERMANECE PNG (screenshot com transparência).
//   - GIF: bypass total (re-encodar mataria a animação).
//   - DESVIO deliberado vs desktop: imagem já na whitelist do servidor E dentro
//     do limite de dimensão passa INTACTA (o desktop re-comprime sempre q0.86;
//     bytes originais são mais fiéis e o servidor aceita — decisão única aqui).

public enum AtlasImagingError: Error, CustomStringConvertible {
    case undecodable
    case encodeFailed
    public var description: String {
        switch self {
        case .undecodable: return "imagem não decodável"
        case .encodeFailed: return "falha ao re-encodar imagem"
        }
    }
}

public enum AtlasImaging {
    public struct Normalized: Sendable {
        public let data: Data
        public let mimeType: String
        public let width: Int
        public let height: Int
    }

    public struct PreparedForComposer: Sendable {
        public let upload: Normalized
        public let preview: Normalized
    }

    public static func normalize(
        _ data: Data, mimeType: String,
        limits: AtlasAttachmentLimits = .canonical
    ) throws -> Normalized {
        try normalizeUpload(data, mimeType: mimeType, limits: limits, previewMaximumPixelSize: nil).upload
    }

    private struct NormalizedUpload {
        let upload: Normalized
        let previewImage: CGImage?
    }

    private static func normalizeUpload(
        _ data: Data,
        mimeType: String,
        limits: AtlasAttachmentLimits,
        previewMaximumPixelSize: Int?
    ) throws -> NormalizedUpload {
        let mime = mimeType.lowercased()

        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw AtlasImagingError.undecodable
        }
        // CGImageSourceCreateWithData é lazy — só as properties provam que os
        // bytes decodam de verdade (lixo sem elas NÃO pode pegar o fast path).
        let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let width = props?[kCGImagePropertyPixelWidth] as? Int ?? 0
        let height = props?[kCGImagePropertyPixelHeight] as? Int ?? 0
        guard width > 0, height > 0 else { throw AtlasImagingError.undecodable }

        // GIF: nunca re-encodar (perderia frames)
        if mime == "image/gif" {
            let previewImage = try previewMaximumPixelSize.map { try thumbnail(from: source, maximumPixelSize: $0) }
            return NormalizedUpload(
                upload: Normalized(data: data, mimeType: "image/gif", width: width, height: height),
                previewImage: previewImage
            )
        }

        let serverSafe = AtlasAttachmentClassifier.supportedImageMime.contains(mime)
        let needsResize = max(width, height) > limits.maxImageDimension

        // Fast path: já aceita pelo servidor e dentro da dimensão → intacta
        if serverSafe && !needsResize {
            let previewImage: CGImage?
            if previewMaximumPixelSize != nil {
                guard let full = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                    throw AtlasImagingError.undecodable
                }
                previewImage = full
            } else {
                previewImage = nil
            }
            return NormalizedUpload(
                upload: Normalized(data: data, mimeType: mime == "image/jpg" ? "image/jpeg" : mime,
                                   width: width, height: height),
                previewImage: previewImage
            )
        }

        // Decode (com resize + transform EXIF quando necessário)
        let cgImage: CGImage
        if needsResize {
            cgImage = try thumbnail(from: source, maximumPixelSize: limits.maxImageDimension)
        } else {
            guard let full = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                throw AtlasImagingError.undecodable
            }
            cgImage = full
        }

        // PNG com alpha permanece PNG; resto (HEIC, TIFF, oversized JPEG…) vira JPEG q0.86
        let keepPng = mime == "image/png" && hasAlpha(cgImage)
        return NormalizedUpload(
            upload: try encode(
                cgImage,
                preservingPng: keepPng,
                jpegQuality: limits.imageJpegQuality
            ),
            previewImage: cgImage
        )
    }

    /// Preview pequeno para a casca decodificar durante o render sem manter a
    /// imagem de upload (até 2048px) duplicada em memória.
    public static func preview(
        _ data: Data,
        mimeType: String,
        maximumPixelSize: Int = 256
    ) throws -> Normalized {
        guard maximumPixelSize > 0,
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw AtlasImagingError.undecodable
        }
        let image = try thumbnail(from: source, maximumPixelSize: maximumPixelSize)
        return try preview(image, mimeType: mimeType, maximumPixelSize: maximumPixelSize)
    }

    public static func preview(
        _ image: CGImage,
        mimeType: String,
        maximumPixelSize: Int = 256
    ) throws -> Normalized {
        let image = try downscale(image, maximumPixelSize: maximumPixelSize)
        let keepPng = mimeType.lowercased() == "image/png" && hasAlpha(image)
        return try encode(image, preservingPng: keepPng, jpegQuality: 0.72)
    }

    /// Faz decode/resize/compress fora do actor chamador. O model iOS é
    /// `@MainActor`; esta fronteira impede que fotos grandes bloqueiem input,
    /// animação ou scroll enquanto o upload e o thumbnail são preparados.
    public static func prepareForComposer(
        _ data: Data,
        mimeType: String,
        maximumPreviewPixelSize: Int = 256
    ) async throws -> PreparedForComposer {
        let task = Task<PreparedForComposer, Error>.detached(priority: .userInitiated) {
            try Task.checkCancellation()
            let normalized = try normalizeUpload(
                data,
                mimeType: mimeType,
                limits: .canonical,
                previewMaximumPixelSize: maximumPreviewPixelSize > 0 ? maximumPreviewPixelSize : nil
            )
            let upload = normalized.upload
            try Task.checkCancellation()
            let thumbnail: Normalized
            if let previewImage = normalized.previewImage {
                thumbnail = try preview(
                    previewImage,
                    mimeType: upload.mimeType,
                    maximumPixelSize: maximumPreviewPixelSize
                )
            } else {
                thumbnail = try preview(
                    upload.data,
                    mimeType: upload.mimeType,
                    maximumPixelSize: maximumPreviewPixelSize
                )
            }
            return PreparedForComposer(upload: upload, preview: thumbnail)
        }
        return try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            task.cancel()
        }
    }

    private static func thumbnail(from source: CGImageSource, maximumPixelSize: Int) throws -> CGImage {
        guard maximumPixelSize > 0 else { throw AtlasImagingError.undecodable }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw AtlasImagingError.undecodable
        }
        return image
    }

    private static func hasAlpha(_ image: CGImage) -> Bool {
        switch image.alphaInfo {
        case .premultipliedLast, .premultipliedFirst, .last, .first: return true
        default: return false
        }
    }

    private static func downscale(_ image: CGImage, maximumPixelSize: Int) throws -> CGImage {
        guard maximumPixelSize > 0 else { throw AtlasImagingError.undecodable }
        let largest = max(image.width, image.height)
        guard largest > maximumPixelSize else { return image }

        let scale = Double(maximumPixelSize) / Double(largest)
        let width = max(1, Int((Double(image.width) * scale).rounded()))
        let height = max(1, Int((Double(image.height) * scale).rounded()))
        let alphaInfo: CGImageAlphaInfo = hasAlpha(image) ? .premultipliedLast : .noneSkipLast
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | alphaInfo.rawValue
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            throw AtlasImagingError.encodeFailed
        }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let scaled = context.makeImage() else { throw AtlasImagingError.encodeFailed }
        return scaled
    }

    private static func encode(
        _ image: CGImage,
        preservingPng: Bool,
        jpegQuality: Double
    ) throws -> Normalized {
        let data = NSMutableData()
        let type: UTType = preservingPng ? .png : .jpeg
        guard let destination = CGImageDestinationCreateWithData(
            data, type.identifier as CFString, 1, nil
        ) else {
            throw AtlasImagingError.encodeFailed
        }
        let options: [CFString: Any] = preservingPng
            ? [:]
            : [kCGImageDestinationLossyCompressionQuality: jpegQuality]
        CGImageDestinationAddImage(destination, image, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            throw AtlasImagingError.encodeFailed
        }
        return Normalized(
            data: data as Data,
            mimeType: preservingPng ? "image/png" : "image/jpeg",
            width: image.width,
            height: image.height
        )
    }
}
