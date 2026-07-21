import SwiftUI
import UIKit
import AtlasCore

// Selection helpers — peel de ArtifactSheet.

extension ArtifactSheet {
    var artifacts: AtlasTraceArtifacts? { reviews.artifactsByTrace[traceId] }
    var items: [AtlasTraceArtifacts.Item] {
        guard artifacts?.state == .available else { return [] }
        return artifacts?.items ?? []
    }
    var selected: AtlasTraceArtifacts.Item? {
        items.first { $0.id == selectedID } ?? items.first
    }
}
