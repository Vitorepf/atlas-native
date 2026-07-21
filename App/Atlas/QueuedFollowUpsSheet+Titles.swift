import SwiftUI

// Cycle 040 fuse → QueuedFollowUpsSheet+Titles.swift

extension QueuedFollowUpsSheet {
    func queueSheetA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.queueSheet)
            .accessibilityLabel(spokenQueueSheetLabel())
            .accessibilityHint("promover ou remover só mensagens reais da fila do model")
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    var queueSheetBodyBranch: some View {
        if model.queuedMessages.isEmpty {
            emptyQueueDismiss
        } else {
            sheetContent
        }
    }
}

extension QueuedFollowUpsSheet {
    var emptyQueueDismiss: some View {
        Color.clear.onAppear { dismiss() }
    }
}

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
