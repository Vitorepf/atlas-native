import SwiftUI
import AtlasCore

// Attention/wait icons — peel de ExecutionStateCard+Icon.
// Wait → ExecutionStateCard+Icon+Attention+Wait.swift

extension ExecutionStateCard {
    var iconAttention: String? {
        if let wait = iconWait { return wait }
        switch state.kind {
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        default: return nil
        }
    }
}
