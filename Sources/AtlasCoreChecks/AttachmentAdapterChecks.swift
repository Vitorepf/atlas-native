import Foundation
import AtlasCore

public func runAttachmentAdapterChecks(_ check: (String, Bool) -> Void) {
    print("\nRich Input · adapters nativos (C3):")
    do {
        let pdf = AtlasAttachmentAdapter.data(
            Data("%PDF".utf8), fileName: "prova.pdf", mimeType: "application/pdf",
            source: "files", identity: "file-1"
        )
        check("fileImporter → AttachmentInput pdf", pdf.kind == .pdf && pdf.source == "files")

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
