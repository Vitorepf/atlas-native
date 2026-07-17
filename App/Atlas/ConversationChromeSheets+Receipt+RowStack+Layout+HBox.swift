import SwiftUI
import AtlasCore

// Receipt HBox — peel de ConversationChromeSheets+Receipt+RowStack+Layout.

extension ConversationHandoffReceipt {
    var receiptRowHBox: some View {
        HStack(spacing: 9) {
            receiptRowLeading
            Spacer(minLength: 0)
        }
    }
}
