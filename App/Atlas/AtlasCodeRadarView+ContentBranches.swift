import AtlasCore
import SwiftUI

// Radar loaded/failed branches — peel de AtlasCodeRadarView+Content.
// Failed → AtlasCodeRadarView+ContentFailed.swift

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarLoadedOrEmpty: some View {
        if let workspace = model.workspace {
            AtlasCodeRadarLoadedContent(workspace: workspace, model: model, onOpenRepo: onOpenRepo)
        } else {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(spokenEmptyWorkspace())
        }
    }
}
