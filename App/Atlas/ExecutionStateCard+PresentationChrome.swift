import SwiftUI
import AtlasCore

// Tint — peel de ExecutionStateCard+Presentation.
// Icon → ExecutionStateCard+Icon.swift

extension ExecutionStateCard {
    var tint: Color {
        switch state.kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        case .failed: return AtlasTheme.domOperacional
        case .replanning, .completed: return AtlasTheme.domAutonomos
        }
    }
}
