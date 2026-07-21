import SwiftUI

// Conteúdo da fila — peel de QueuedFollowUpsSheet.
// Caption → QueuedFollowUpsSheet+Caption.swift
// MessageRows → QueuedFollowUpsSheet+Content+MessageRows.swift

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
