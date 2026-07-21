import AtlasCore
import SwiftUI

// Healthy mirrored/pending — peel de AtlasCodeMirrorCard+Headline+Healthy.

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyActive: some View {
        switch response.state {
        case .mirrored:
            headlineHealthyMirrored
        case .pending(let commits):
            headlineHealthyPending(commits: commits)
        default:
            EmptyView()
        }
    }
}
