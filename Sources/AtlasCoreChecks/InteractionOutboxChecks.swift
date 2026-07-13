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
        ), followUpId: "follow-up-1")
        let clientId = prepared.input.clientId ?? ""
        check("prepare gera UUID estável", UUID(uuidString: clientId) != nil)
        check("primeiro prepare não era pending", !prepared.wasPending)
        check("outbox guarda vínculo da fila local", prepared.followUpId == "follow-up-1")

        let relaunched = InteractionOutbox(fileURL: file)
        let pending = await relaunched.pending()
        check("pending sobrevive a nova instância/relaunch",
              pending.count == 1 && pending.first?.clientId == clientId)
        check("relaunch recupera vínculo da fila", await relaunched.followUpId(clientId: clientId) == "follow-up-1")
        check("relaunch preserva payload e rich input",
              pending.first?.payload?["compute_effort"]?.stringValue == "deep" &&
              pending.first?.uploadedDocuments == ["up-doc"] &&
              pending.first?.richInputPayload == rich)

        let preparedAgain = try await relaunched.prepare(pending[0])
        check("prepare preserva clientId no retry", preparedAgain.wasPending && preparedAgain.input.clientId == clientId)
        check("retry preserva vínculo da fila", preparedAgain.followUpId == "follow-up-1")

        try await relaunched.remove(clientId: clientId)
        let afterRemoval = InteractionOutbox(fileURL: file)
        check("sucesso remove outbox de forma durável", await afterRemoval.pending().isEmpty)

        let legacyFile = directory.appendingPathComponent("legacy.json")
        let legacyClientId = "c26d4f84-1ed0-4d92-ab3d-33bf61f56cea"
        let legacyJSON: [String: Any] = [
            "schemaVersion": 1,
            "pending": [[
                "inputText": "retomar turno legado",
                "clientId": legacyClientId,
            ]],
        ]
        let legacyData = try JSONSerialization.data(withJSONObject: legacyJSON)
        try legacyData.write(to: legacyFile, options: [.atomic])
        let migratedLegacy = InteractionOutbox(fileURL: legacyFile)
        let legacyPending = await migratedLegacy.pending()
        check("outbox v1 migra sem perder turno pendente",
              legacyPending.first?.clientId == legacyClientId &&
              legacyPending.first?.inputText == "retomar turno legado")
    } catch {
        check("outbox durável não deveria falhar", false)
        print("    erro: \(error)")
    }
}
