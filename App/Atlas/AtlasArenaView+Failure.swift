import SwiftUI
import AtlasCore

// Failure — peel de AtlasArenaView+States.
// Exception → AtlasArenaView+Exception.swift
// Retry → AtlasArenaView+FailureRetry.swift
// Copy → AtlasArenaView+FailureCopy.swift

extension AtlasArenaView {
    var networkFailureCard: some View {
        let kind = model.loadFailureKind
        let hasToken = session.hasToken
        return VStack(alignment: .leading, spacing: 10) {
            networkFailureCopy(kind: kind, hasToken: hasToken)
            networkFailureRetry
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)). \(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))")
    }
}
