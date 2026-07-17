import SwiftUI
import AtlasCore

// Attention spoken kinds — peel de ExecutionStateCard+Presentation.
// Wait → ExecutionStateCard+Presentation+Attention+Wait.swift

extension ExecutionStateCard {
    var spokenKindAttention: String? {
        if let wait = spokenKindWait { return wait }
        switch state.kind {
        case .recovering: return "reconectando"
        case .replanning: return "replanejando"
        default: return nil
        }
    }
}
