import SwiftUI
import AtlasCore

// Failed branch — peel de AtlasArenaView+Content.

extension AtlasArenaView {
    @ViewBuilder
    var failedOrUnavailableCard: some View {
        if model.isDomainUnavailable {
            domainUnavailableCard
        } else {
            networkFailureCard
        }
    }
}
