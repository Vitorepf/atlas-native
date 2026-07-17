import SwiftUI
import AtlasCore

// Retry button — peel de AtlasArenaView+Failure.

extension AtlasArenaView {
    @ViewBuilder
    var networkFailureRetry: some View {
        if session.hasToken {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                Task { await model.load() }
            } label: {
                Text("Tentar de novo")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.accent)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
            .accessibilityLabel("tentar de novo")
            .accessibilityHint("reconecta ao servidor Atlas")
        }
    }
}
