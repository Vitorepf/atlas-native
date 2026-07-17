import SwiftUI
import AtlasCore

// Status + receipt — peel de ArenaRunSheet.

extension ArenaRunSheet {
    @ViewBuilder
    var statusBlocks: some View {
        if let error = model.controlError {
            Text(error)
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.alert)
                .accessibilityLabel(spokenErrorLabel(error))
                .transition(reduceMotion ? .identity : .opacity)
        }
        if let receipt = model.lastStartReceipt {
            receiptCard(receipt)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 8)))
        }
    }
}
