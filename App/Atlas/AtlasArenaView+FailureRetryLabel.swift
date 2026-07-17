import SwiftUI
import AtlasCore

// Retry label — peel de AtlasArenaView+FailureRetry.

extension AtlasArenaView {
    var networkFailureRetryLabel: some View {
        Text("Tentar de novo")
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.accent)
    }
}
