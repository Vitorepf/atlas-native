import Foundation
import AtlasCore

public func runAtlasQueuedFollowUpChecks(_ check: (String, Bool) -> Void) async {
    print("\nAtlas AI · fila FIFO durável (C11):")
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("atlas-follow-up-check-\(UUID().uuidString)", isDirectory: true)
    let file = directory.appendingPathComponent("queued.json")
    defer { try? FileManager.default.removeItem(at: directory) }

    do {
        let first = QueuedFollowUpStore(fileURL: file)
        let ignored = try await first.enqueue(text: "  ", scope: "thread-a")
        let one = try await first.enqueue(text: "Revise o diff", scope: "thread-a")
        let two = try await first.enqueue(text: "Rode os gates", scope: "thread-a")

        check("fila ignora follow-up vazio", ignored == nil)
        let initial = await first.messages(scope: "thread-a")
        check("fila preserva ordem FIFO", initial.map(\.text) == ["Revise o diff", "Rode os gates"])

        if let two {
            try await first.promote(id: two.id, scope: "thread-a")
        }
        let promoted = await first.messages(scope: "thread-a")
        check("promover define o próximo turno sem remover", promoted.map(\.text) == ["Rode os gates", "Revise o diff"])

        let relaunched = QueuedFollowUpStore(fileURL: file)
        let restored = await relaunched.messages(scope: "thread-a")
        check("fila sobrevive ao relaunch", restored.map(\.text) == ["Rode os gates", "Revise o diff"])

        let peeked = await relaunched.peek(scope: "thread-a")
        let countAfterPeek = await relaunched.messages(scope: "thread-a").count
        check("cabeça pode ser preparada sem sair da fila", peeked?.text == "Rode os gates" && countAfterPeek == 2)

        let next = try await relaunched.dequeue(scope: "thread-a")
        let afterDequeue = await relaunched.messages(scope: "thread-a")
        check("dequeue drena somente a cabeça FIFO", next?.text == "Rode os gates" && afterDequeue.map(\.text) == ["Revise o diff"])

        if let one {
            try await relaunched.remove(id: one.id, scope: "thread-a")
        }
        let afterRemoval = QueuedFollowUpStore(fileURL: file)
        check("remoção é durável", await afterRemoval.messages(scope: "thread-a").isEmpty)

        _ = try await relaunched.enqueue(text: "Continue a auditoria", scope: "local-a")
        _ = try await relaunched.enqueue(text: "Faça a revisão final", scope: "thread-b")
        try await relaunched.migrate(scope: "local-a", to: "thread-b")
        let migrated = await relaunched.messages(scope: "thread-b")
        check("migração de conversa nova preserva ordem temporal", migrated.map(\.text) == ["Continue a auditoria", "Faça a revisão final"])
        check("migração remove o escopo provisório", await relaunched.messages(scope: "local-a").isEmpty)
    } catch {
        check("fila FIFO durável não deveria falhar", false)
        print("    erro: \(error)")
    }
}
