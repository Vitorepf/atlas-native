import SwiftUI
import AtlasCore

// Receipt row — peel de ConversationChromeSheets+Receipt.

extension ConversationHandoffReceipt {
    var receiptRowStack: some View {
        HStack(spacing: 9) {
            receiptIcon
            receiptCopy
            Spacer(minLength: 0)
        }
    }
}
