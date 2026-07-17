import SwiftUI
import AtlasCore

// Receipt layout — peel de ConversationChromeSheets+Receipt+RowStack.

extension ConversationHandoffReceipt {
    var receiptRowLayout: some View {
        HStack(spacing: 9) {
            receiptRowLeading
            Spacer(minLength: 0)
        }
    }
}
