import Foundation
import AtlasCore

public func runAttachmentAdapterChecks(_ check: (String, Bool) -> Void) {
    print("\nRich Input · adapters nativos (C3):")
    do {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("atlas-file-source-\(UUID().uuidString).pdf")
        let fileBytes = Data("%PDF-1.7 atlas file source".utf8)
        try fileBytes.write(to: fileURL, options: .atomic)
        defer { try? FileManager.default.removeItem(at: fileURL) }
        let pdf = try AtlasAttachmentAdapter.file(
            url: fileURL, mimeType: "application/pdf", identity: "file-1"
        )
        let suffix = try pdf.bytes.read(offset: 9, length: 5)
        check("fileImporter → FileByteSource pdf com leitura por offset",
              pdf.kind == .pdf && pdf.source == "files" &&
              pdf.bytes.totalBytes == fileBytes.count &&
              String(data: suffix, encoding: .utf8) == "atlas")

        let camera = AtlasAttachmentAdapter.data(
            Data([1, 2, 3]), fileName: "camera.jpg", mimeType: "image/jpeg",
            source: "camera", identity: "camera-1", width: 100, height: 80
        )
        check("câmera → mesmo AttachmentInput", camera.kind == .image && camera.width == 100)

        let clipboard = AtlasAttachmentAdapter.clipboard(text: "let atlas = true")
        let bytes = try clipboard.bytes.read(offset: 0, length: clipboard.bytes.totalBytes)
        check("clipboard → texto no engine único",
              clipboard.kind == .text && clipboard.source == "clipboard" &&
              String(data: bytes, encoding: .utf8) == "let atlas = true")
    } catch {
        check("adapters C3 não deveriam falhar", false)
    }
}
