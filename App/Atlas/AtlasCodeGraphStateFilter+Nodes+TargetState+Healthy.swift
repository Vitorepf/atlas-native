import SwiftUI
import AtlasCore

// Healthy target states — peel de AtlasCodeGraphStateFilter+Nodes+TargetState.

extension AtlasCodeGraphStateFilter {
    var targetStateHealthy: AtlasCodeNodeState? {
        switch self {
        case .onMain: return .onMain
        case .healed: return .healed
        default: return nil
        }
    }
}
