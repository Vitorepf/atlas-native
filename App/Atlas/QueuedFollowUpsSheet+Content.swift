import SwiftUI

// Conteúdo da fila — peel de QueuedFollowUpsSheet.
// Caption → QueuedFollowUpsSheet+Caption.swift

extension QueuedFollowUpsSheet {
    var sheetContent: some View {
        let messages = model.queuedMessages
        let total = messages.count
        return SheetShell(title: sheetTitle(count: total)) {
            queueOrderCaption(total: total)
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
}
