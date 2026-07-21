import SwiftUI
import AtlasCore

// IDLE-COMPRESS body

// --- QueuedFollowUpsSheet+A11yShell.swift ---
extension QueuedFollowUpsSheet {
    func queueSheetA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.queueSheet)
            .accessibilityLabel(spokenQueueSheetLabel())
            .accessibilityHint("promover ou remover só mensagens reais da fila do model")
    }
}

// --- QueuedFollowUpsSheet+Caption.swift ---
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

// --- QueuedFollowUpsSheet+Content+MessageRows.swift ---
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

// --- QueuedFollowUpsSheet+Content.swift ---
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

// --- QueuedFollowUpsSheet+EmptyBranch.swift ---
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

// --- QueuedFollowUpsSheet+EmptyDismiss.swift ---
extension QueuedFollowUpsSheet {
    var emptyQueueDismiss: some View {
        Color.clear.onAppear { dismiss() }
    }
}

// --- QueuedFollowUpsSheet+Titles.swift ---
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

