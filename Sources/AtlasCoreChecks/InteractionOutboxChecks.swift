import Foundation
import AtlasCore

public func runInteractionOutboxChecks(_ check: (String, Bool) -> Void) async {
    print("\nAtlas AI · outbox durável (C2):")
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("atlas-outbox-check-\(UUID().uuidString)", isDirectory: true)
    let file = directory.appendingPathComponent("pending.json")
    defer { try? FileManager.default.removeItem(at: directory) }

    do {
        let rich = AtlasRichInputPayload(
            uploadedDocumentIds: ["up-doc"],
            textBlocks: [.init(fileName: "nota.md", mimeType: "text/markdown",
                               language: "markdown", content: "# Atlas")]
        )
        let first = InteractionOutbox(fileURL: file)
        let prepared = try await first.prepare(CreateAiInteractionInput(
            inputText: "boa noite",
            payload: JSONObject(["compute_effort": .string("deep")]),
            uploadedDocuments: ["up-doc"],
            richInputPayload: rich
        ))
        let clientId = prepared.input.clientId ?? ""
        check("prepare gera UUID estável", UUID(uuidString: clientId) != nil)
        check("primeiro prepare não era pending", !prepared.wasPending)

        let relaunched = InteractionOutbox(fileURL: file)
        let pending = await relaunched.pending()
        check("pending sobrevive a nova instância/relaunch",
              pending.count == 1 && pending.first?.clientId == clientId)
        check("relaunch preserva payload e rich input",
              pending.first?.payload?["compute_effort"]?.stringValue == "deep" &&
              pending.first?.uploadedDocuments == ["up-doc"] &&
              pending.first?.richInputPayload == rich)

        let preparedAgain = try await relaunched.prepare(pending[0])
        check("prepare preserva clientId no retry", preparedAgain.wasPending && preparedAgain.input.clientId == clientId)

        try await relaunched.remove(clientId: clientId)
        let afterRemoval = InteractionOutbox(fileURL: file)
        check("sucesso remove outbox de forma durável", await afterRemoval.pending().isEmpty)
    } catch {
        check("outbox durável não deveria falhar", false)
        print("    erro: \(error)")
    }
}
