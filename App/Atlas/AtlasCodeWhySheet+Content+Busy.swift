import SwiftUI
import AtlasCore

/// Why busy content — peel de AtlasCodeWhySheet+Content.

extension AtlasCodeWhySheet {
    @ViewBuilder var whyBusyContent: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            whyLoadingOrFailed
        default:
            EmptyView()
        }
    }
}
