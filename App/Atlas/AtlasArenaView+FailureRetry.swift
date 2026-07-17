import SwiftUI
import AtlasCore

// Retry button — peel de AtlasArenaView+Failure.
// Label → AtlasArenaView+FailureRetryLabel.swift
// A11y → AtlasArenaView+FailureRetryA11y.swift

extension AtlasArenaView {
    @ViewBuilder
    var networkFailureRetry: some View {
        if session.hasToken {
            networkFailureRetryA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    Task { await model.load() }
                } label: {
                    networkFailureRetryLabel
                }
            )
        }
    }
}
