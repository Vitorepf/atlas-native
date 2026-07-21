import SwiftUI
import AtlasCore

// Receipt layout — peel de ConversationChromeSheets+Receipt+RowStack.
// HBox → ConversationChromeSheets+Receipt+RowStack+Layout+HBox.swift

extension ConversationHandoffReceipt {
    var receiptRowLayout: some View {
        receiptRowHBox
    }
}
