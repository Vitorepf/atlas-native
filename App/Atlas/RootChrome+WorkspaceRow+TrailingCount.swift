import SwiftUI

// Trailing count + chevron — peel de RootChrome+WorkspaceRow+Trailing.

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailingCount: some View {
        if let count {
            // Número é meta: mono editorial quieto (ausência = ausência).
            Text("\(count)")
                .font(AtlasFont.mono(12, .medium))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
        Image(systemName: "chevron.right")
            .atlasSans(11, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.55))
            .accessibilityHidden(true)
    }
}
