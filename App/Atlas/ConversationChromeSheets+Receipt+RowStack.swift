import SwiftUI
import AtlasCore

// Receipt row — peel de ConversationChromeSheets+Receipt.
// Leading → ConversationChromeSheets+Receipt+RowStack+Leading.swift
// Layout → ConversationChromeSheets+Receipt+RowStack+Layout.swift

extension ConversationHandoffReceipt {
    var receiptRowStack: some View {
        receiptRowLayout
    }
}
