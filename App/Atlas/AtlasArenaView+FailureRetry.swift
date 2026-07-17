import SwiftUI
import AtlasCore

// Retry button — peel de AtlasArenaView+Failure.
// Label → AtlasArenaView+FailureRetryLabel.swift

extension AtlasArenaView {
    @ViewBuilder
    var networkFailureRetry: some View {
        if session.hasToken {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                Task { await model.load() }
            } label: {
                networkFailureRetryLabel
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
            .accessibilityLabel("tentar de novo")
            .accessibilityHint("reconecta ao servidor Atlas")
        }
    }
}
