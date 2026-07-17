import SwiftUI
import AtlasCore

// Tipografia do relógio LiveNow — peel de LiveNowRow+ClockRunning.

extension LiveNowRow {
    func clockText(_ value: String) -> some View {
        Text(value)
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textSecondary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
    }
}
