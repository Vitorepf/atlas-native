import SwiftUI
import AtlasCore

// Patch card shell — peel de ChangeReviewDiffSection.

extension ChangeReviewPatchCard {
    var patchCardShell: some View {
        patchCardChrome { patchCardBody }
    }
}
