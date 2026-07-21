import SwiftUI
import AtlasCore

// Detail line — peel de ExecutionStateCard.

extension ExecutionStateCard {
    @ViewBuilder
    var detailLine: some View {
        if let detail = state.detail {
            Text(detail)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}
