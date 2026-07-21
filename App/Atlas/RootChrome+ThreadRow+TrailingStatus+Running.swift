import SwiftUI
import AtlasCore

// Running branch — peel de RootChrome+ThreadRow+TrailingStatus.

extension ThreadRow {
    @ViewBuilder
    var rowTrailingRunning: some View {
        Text("executando").font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
    }
}
