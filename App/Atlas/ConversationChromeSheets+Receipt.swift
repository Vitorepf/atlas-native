import SwiftUI
import AtlasCore

// Recibo de continuidade — peel de ConversationChromeSheets; selos → +Seals.
// Copy → ConversationChromeSheets+Receipt+Copy.swift
// Lead → ConversationChromeSheets+Receipt+Lead.swift
// Chrome → ConversationChromeSheets+ReceiptChrome.swift
// RowStack → ConversationChromeSheets+Receipt+RowStack.swift

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isReady: Bool { handoff.status == "ready" }
    var isPending: Bool { handoff.status == "pending" }

    var body: some View {
        receiptChrome(receiptRowStack)
    }
}
