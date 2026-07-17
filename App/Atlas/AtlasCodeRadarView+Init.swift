import AtlasCore
import SwiftUI

// Init — peel de AtlasCodeRadarView.

extension AtlasCodeRadarView {
    init(client: AtlasClient, onOpenRepo: @escaping (String) -> Void) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.onOpenRepo = onOpenRepo
    }
}
