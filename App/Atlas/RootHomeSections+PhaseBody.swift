import SwiftUI
import AtlasCore

// Phase router — peel de RootHomeSections.

extension RootHomeSections {
    @ViewBuilder
    var phaseBody: some View {
        switch session.phase {
        case .idle where session.threads.isEmpty, .loading where session.threads.isEmpty:
            loadingHome
        case .failed where session.threads.isEmpty:
            failureSection
        default:
            loadedHome
        }
    }
}
