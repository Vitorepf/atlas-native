import SwiftUI
import AtlasCore

// Selection sync — peel de ArtifactSheet+Lifecycle.

extension ArtifactSheet {
    func artifactSheetSyncSelection(ids: [String]) {
        if selectedID == nil || selectedID.map({ !ids.contains($0) }) == true {
            selectedID = ids.first
        }
    }
}
