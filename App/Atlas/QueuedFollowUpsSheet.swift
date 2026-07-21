import AtlasCore
import SwiftUI

// Cycle 043 fuse → QueuedFollowUpsSheet.swift

/// Folha C11: mensagens enfileiradas durante execução — promover (enviar agora)
/// ou remover. Só renderiza o que `ConversationModel.queuedMessages` expõe.
struct QueuedFollowUpsSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dismiss) var dismiss

    var model: ConversationModel

    var body: some View {
        queueSheetA11yShell(queueSheetBodyBranch)
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    func queueMessageRows(messages: [QueuedMessage]) -> some View {
        let total = messages.count
        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
            QueuedFollowUpRow(
                message: message,
                index: index,
                total: total,
                onPromote: { Task { await model.promote(id: message.id) } },
                onRemove: { Task { await model.removeQueued(id: message.id) } }
            )
            .transition(reduceMotion ? .identity : .opacity)
        }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: messages.map(\.id))
    }
}

extension QueuedFollowUpsSheet {
    var sheetContent: some View {
        let messages = model.queuedMessages
        let total = messages.count
        return SheetShell(title: sheetTitle(count: total)) {
            queueOrderCaption(total: total)
            queueMessageRows(messages: messages)
        }
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    func queueOrderCaption(total: Int) -> some View {
        if total > 1 {
            Text("ordem da fila · a cabeça envia quando o turno terminar")
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(
                    "fila ordenada; a primeira mensagem envia quando o turno atual terminar"
                )
        }
    }
}

extension QueuedFollowUpsSheet {
    func queueSheetA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.queueSheet)
            // Contain without fused sheet label so queue rows stay focusable.
            .accessibilityElement(children: .contain)
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
