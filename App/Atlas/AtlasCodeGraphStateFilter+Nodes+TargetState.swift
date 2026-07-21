import SwiftUI
import AtlasCore

// Target state — peel de AtlasCodeGraphStateFilter+Nodes.
// Healthy → AtlasCodeGraphStateFilter+Nodes+TargetState+Healthy.swift

extension AtlasCodeGraphStateFilter {
    var targetState: AtlasCodeNodeState {
        if let healthy = targetStateHealthy { return healthy }
        switch self {
        case .violating: return .violating
        case .all, .history: return .history
        default: return .history
        }
    }
}
