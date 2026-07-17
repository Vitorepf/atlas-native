import SwiftUI
import AtlasCore

// Phase router — peel de RootHomeSections.

extension RootHomeSections {
    @ViewBuilder
    var phaseBody: some View {
        homeLoadingGate
    }
}
