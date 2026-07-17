import SwiftUI
import AtlasCore

// Digest section in stack — peel de AutonomosLoadedSection+StackHead.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackDigest: some View {
        loadedStackNextDigest
        loadedStackOperationDigest
    }
}
