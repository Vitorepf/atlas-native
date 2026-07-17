import SwiftUI
import AtlasCore

// Thread trailing status — peel de RootChrome+ThreadRow+Trailing.

extension ThreadRow {
    @ViewBuilder
    var rowTrailingStatus: some View {
        if isNew && !isRunning {
            Text("novo")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Capsule().fill(AtlasTheme.goldVeil))
                .accessibilityHidden(true)
        }
        if isRunning {
            Text("executando").font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        } else {
            Text("\(thread.messageCount)")
                .font(.system(size: 16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}
