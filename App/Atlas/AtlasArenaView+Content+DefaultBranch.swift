import SwiftUI
import AtlasCore

// Default branch — peel de AtlasArenaView+Content.

extension AtlasArenaView {
    @ViewBuilder
    var contentDefaultBranch: some View {
        if let composite = model.composite {
            loadedArenaContent(composite)
        } else {
            domainUnavailableCard
        }
    }
}
