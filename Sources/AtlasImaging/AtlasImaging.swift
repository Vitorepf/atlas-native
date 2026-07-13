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
            return Normalized(data: data, mimeType: "image/gif", width: width, height: height)
        }

        let serverSafe = AtlasAttachmentClassifier.supportedImageMime.contains(mime)
        let needsResize = max(width, height) > limits.maxImageDimension

        // Fast path: já aceita pelo servidor e dentro da dimensão → intacta
        if serverSafe && !needsResize {
            return Normalized(data: data, mimeType: mime == "image/jpg" ? "image/jpeg" : mime,
                              width: width, height: height)
        }

        // Decode (com resize + transform EXIF quando necessário)
        let cgImage: CGImage
        if needsResize {
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: limits.maxImageDimension,
                kCGImageSourceCreateThumbnailWithTransform: true,
            ]
            guard let thumb = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
                throw AtlasImagingError.undecodable
            }
            cgImage = thumb
        } else {
            guard let full = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                throw AtlasImagingError.undecodable
            }
            cgImage = full
        }

        // PNG com alpha permanece PNG; resto (HEIC, TIFF, oversized JPEG…) vira JPEG q0.86
        let hasAlpha: Bool = {
            switch cgImage.alphaInfo {
            case .premultipliedLast, .premultipliedFirst, .last, .first: return true
            default: return false
            }
        }()
        let keepPng = mime == "image/png" && hasAlpha
        return try encode(
            cgImage,
            preservingPng: keepPng,
            jpegQuality: limits.imageJpegQuality
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
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw AtlasImagingError.undecodable
        }
        let hasAlpha: Bool
        switch image.alphaInfo {
        case .premultipliedLast, .premultipliedFirst, .last, .first: hasAlpha = true
        default: hasAlpha = false
        }
        let keepPng = mimeType.lowercased() == "image/png" && hasAlpha
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
            let upload = try normalize(data, mimeType: mimeType)
            try Task.checkCancellation()
            let thumbnail = try preview(
                upload.data,
                mimeType: upload.mimeType,
                maximumPixelSize: maximumPreviewPixelSize
            )
            return PreparedForComposer(upload: upload, preview: thumbnail)
        }
        return try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            task.cancel()
        }
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
