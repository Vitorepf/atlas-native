import SwiftUI
import AtlasCore

// Thread trailing status — peel de RootChrome+ThreadRow+Trailing.
// New → RootChrome+ThreadRow+NewBadge.swift

extension ThreadRow {
    @ViewBuilder
    var rowTrailingStatus: some View {
        newThreadBadge
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
