import SwiftUI

// Queue sheet titles — peel de QueuedFollowUpsSheet+Caption.

extension QueuedFollowUpsSheet {
    func sheetTitle(count: Int) -> String {
        count == 1 ? "Fila · 1" : "Fila · \(count)"
    }

    func spokenQueueSheetLabel() -> String {
        let n = model.queuedMessages.count
        if n == 0 { return "fila vazia" }
        return n == 1 ? "fila, 1 mensagem" : "fila, \(n) mensagens"
    }
}
