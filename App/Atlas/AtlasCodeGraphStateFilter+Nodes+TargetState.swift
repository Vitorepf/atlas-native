import SwiftUI
import AtlasCore

// Target state — peel de AtlasCodeGraphStateFilter+Nodes.

extension AtlasCodeGraphStateFilter {
    var targetState: AtlasCodeNodeState {
        switch self {
        case .all, .history: return .history
        case .onMain: return .onMain
        case .violating: return .violating
        case .healed: return .healed
        }
    }
}
