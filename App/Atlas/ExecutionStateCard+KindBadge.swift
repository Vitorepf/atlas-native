import SwiftUI
import AtlasCore

// Kind badge — peel de ExecutionStateCard+Presentation.
// Attention → ExecutionStateCard+KindBadge+Attention.swift

extension ExecutionStateCard {
    /// Selo 1:1 com `kind` — nunca copy inventada além do mapeamento canônico.
    var kindBadge: String? {
        switch state.kind {
        case .failed: return "FALHOU"
        case .completed: return nil
        default: return kindBadgeAttention
        }
    }
}
