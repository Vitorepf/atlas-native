import Foundation

public enum AttachmentAdapterError: Error, CustomStringConvertible, Sendable {
    case limitReached(Int)

    public var description: String {
        switch self {
        case .limitReached(let maximum): return "limite de \(maximum) anexos atingido"
        }
    }
}

/// Entrada única para Photos, câmera, Files, clipboard e futuro drop/macOS.
/// Adapters só descrevem origem + bytes; upload, hash, retry, resume e payload
/// continuam pertencendo exclusivamente ao `AtlasRichInputEngine`.
public enum AtlasAttachmentAdapter {
    public static func data(
        _ data: Data,
        fileName: String,
        mimeType: String,
        source: String,
        identity: String,
        width: Int? = nil,
        height: Int? = nil
    ) -> AttachmentInput {
        let detected = AtlasAttachmentClassifier.detect(mimeType: mimeType, fileName: fileName)
        return AttachmentInput(
            kind: detected.kind,
            fileName: normalizedFileName(fileName),
            mimeType: mimeType,
            source: source,
            identity: identity,
            bytes: DataByteSource(data),
            width: width,
            height: height
        )
    }

    public static func file(
        url: URL,
        mimeType: String,
        identity: String? = nil
    ) throws -> AttachmentInput {
        let fileName = normalizedFileName(url.lastPathComponent)
        let detected = AtlasAttachmentClassifier.detect(mimeType: mimeType, fileName: fileName)
        return AttachmentInput(
            kind: detected.kind,
            fileName: fileName,
            mimeType: mimeType,
            source: "files",
            identity: identity ?? url.standardizedFileURL.path,
            bytes: try FileByteSource(url: url)
        )
    }

    public static func clipboard(text: String) -> AttachmentInput {
        let bytes = Data(text.utf8)
        return data(
            bytes,
            fileName: "clipboard-\(atlasFnv36(text)).txt",
            mimeType: "text/plain",
            source: "clipboard",
            identity: "clipboard:\(atlasFnv36(text))"
        )
    }

    private static func normalizedFileName(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "anexo" : trimmed
    }
}
