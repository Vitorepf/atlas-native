import SwiftUI
import AtlasCore

// Receipt leading — peel de ConversationChromeSheets+Receipt+RowStack.

extension ConversationHandoffReceipt {
    @ViewBuilder
    var receiptRowLeading: some View {
        receiptIcon
        receiptCopy
    }
}
