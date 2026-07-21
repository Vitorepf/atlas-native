import SwiftUI
import AtlasCore

// Count branch — peel de RootChrome+ThreadRow+TrailingStatus.

extension ThreadRow {
    var rowTrailingCount: some View {
        Text("\(thread.messageCount)")
            .atlasSans(16)
            .foregroundStyle(AtlasTheme.textTertiary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityHidden(true)
    }
}
