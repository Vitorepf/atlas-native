import AtlasCore
import SwiftUI

// Healthy quiet states — peel de AtlasCodeMirrorCard+Headline+Healthy.

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyQuiet: some View {
        switch response.state {
        case .noMirror:
            headlineHealthyNoMirror
        case .unknown:
            headlineHealthyUnknown
        default:
            EmptyView()
        }
    }
}
