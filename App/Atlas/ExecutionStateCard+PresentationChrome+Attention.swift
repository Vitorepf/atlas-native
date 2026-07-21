import SwiftUI
import AtlasCore

// Attention tint — peel de ExecutionStateCard+PresentationChrome.

extension ExecutionStateCard {
    var tintAttention: Color? {
        switch state.kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        default: return nil
        }
    }
}
