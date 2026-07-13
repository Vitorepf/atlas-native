import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import AtlasCore
import AtlasImaging

// F4 — imagens GERADAS programaticamente (CGContext): sem fixtures binárias no
// repo. Roda no runner mac; iOS usa exatamente o mesmo código.

private func makeImage(width: Int, height: Int, alpha: Bool, as type: UTType) -> Data? {
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    let info: UInt32 = alpha
        ? CGImageAlphaInfo.premultipliedLast.rawValue
        : CGImageAlphaInfo.noneSkipLast.rawValue
    guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                              bytesPerRow: 0, space: space, bitmapInfo: info) else { return nil }
    ctx.setFillColor(CGColor(red: 0.85, green: 0.66, blue: 0.35, alpha: alpha ? 0.5 : 1))
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    ctx.setFillColor(CGColor(red: 0.11, green: 0.17, blue: 0.20, alpha: 1))
    ctx.fill(CGRect(x: 0, y: 0, width: width / 2, height: height / 2))
    guard let img = ctx.makeImage() else { return nil }
    let out = NSMutableData()
    guard let dest = CGImageDestinationCreateWithData(out, type.identifier as CFString, 1, nil) else { return nil }
    CGImageDestinationAddImage(dest, img, nil)
    guard CGImageDestinationFinalize(dest) else { return nil }
    return out as Data
}

private func sniff(_ data: Data) -> (mime: String?, width: Int, height: Int) {
    guard let src = CGImageSourceCreateWithData(data as CFData, nil),
          let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] else {
        return (nil, 0, 0)
    }
    let ut = CGImageSourceGetType(src).flatMap { UTType($0 as String) }
    return (ut?.preferredMIMEType,
            props[kCGImagePropertyPixelWidth] as? Int ?? 0,
            props[kCGImagePropertyPixelHeight] as? Int ?? 0)
}

func runAtlasImagingChecks(_ check: (String, Bool) -> Void) {
    print("\nAtlasImaging (ImageIO compartilhado iOS+macOS — HEIC/resize/alpha):")
    let limits = AtlasAttachmentLimits.canonical

    // 1. JPEG pequeno na whitelist → INTACTO (fast path, sem recompressão)
    if let jpeg = makeImage(width: 600, height: 400, alpha: false, as: .jpeg) {
        let n = try? AtlasImaging.normalize(jpeg, mimeType: "image/jpeg")
        check("jpeg 600×400 → intacto (bytes idênticos, fast path)",
              n?.data == jpeg && n?.mimeType == "image/jpeg")
    } else { check("gerar jpeg de teste", false) }

    // 2. JPEG 3000px → resize lado maior 2048, continua JPEG
    if let big = makeImage(width: 3000, height: 1000, alpha: false, as: .jpeg) {
        let n = try? AtlasImaging.normalize(big, mimeType: "image/jpeg")
        let s = n.map { sniff($0.data) }
        check("jpeg 3000×1000 → ≤2048 no lado maior, mime jpeg",
              n?.mimeType == "image/jpeg" && (s?.width ?? 9999) <= limits.maxImageDimension
              && (s?.mime == "image/jpeg"))
    } else { check("gerar jpeg grande de teste", false) }

    // 3. PNG com alpha oversized → resize MAS permanece PNG (alpha preservado)
    if let png = makeImage(width: 2600, height: 300, alpha: true, as: .png) {
        let n = try? AtlasImaging.normalize(png, mimeType: "image/png")
        let s = n.map { sniff($0.data) }
        check("png+alpha 2600px → resize e PERMANECE png",
              n?.mimeType == "image/png" && (s?.mime == "image/png")
              && (s?.width ?? 9999) <= limits.maxImageDimension)
    } else { check("gerar png de teste", false) }

    // 4. HEIC → JPEG (a foto do iPhone; server rejeita HEIC com 422)
    if let heic = makeImage(width: 900, height: 600, alpha: false, as: .heic) {
        let n = try? AtlasImaging.normalize(heic, mimeType: "image/heic")
        let s = n.map { sniff($0.data) }
        check("heic 900×600 → vira JPEG (whitelist do servidor)",
              n?.mimeType == "image/jpeg" && s?.mime == "image/jpeg")
        // e o resultado passa na validação local do engine
        check("heic normalizado passa na whitelist local do engine",
              AtlasAttachmentClassifier.supportedImageMime.contains(n?.mimeType ?? ""))
    } else {
        print("  ⚠ encoder HEIC indisponível neste runner — check pulado (roda no device)")
    }

    // 5. lixo não-imagem → erro claro, nunca sobe
    check("bytes aleatórios → undecodable (falha local clara)",
          (try? AtlasImaging.normalize(Data([0x00, 0x01, 0x02, 0x03]), mimeType: "image/jpeg")) == nil)
}
