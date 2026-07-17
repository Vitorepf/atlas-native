import SwiftUI
import AtlasCore

// Trailing count/badge — peel de WorkspaceRow.

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailing: some View {
        if badge {
            Circle()
                .fill(AtlasTheme.alert)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
        }
        if let count {
            Text("\(count)")
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
