import SwiftUI

// Sheet row label — peel de ConversationChrome+SheetRow.
// Leading → ConversationChrome+SheetRowLabel+Leading.swift
// Trailing → ConversationChrome+SheetRowLabel+Trailing.swift

extension SheetRow {
    var rowLabel: some View {
        HStack(spacing: 12) {
            sheetRowLeading
            Spacer()
            sheetRowTrailing
        }
        .padding(.horizontal, 24).padding(.vertical, 15).contentShape(Rectangle())
    }
}
