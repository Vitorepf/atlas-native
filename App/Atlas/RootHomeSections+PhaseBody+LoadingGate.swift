import SwiftUI
import AtlasCore

// Loading gate — peel de RootHomeSections+PhaseBody.

extension RootHomeSections {
    @ViewBuilder
    var homeLoadingGate: some View {
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
