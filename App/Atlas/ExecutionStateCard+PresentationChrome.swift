import SwiftUI
import AtlasCore

// Tint — peel de ExecutionStateCard+Presentation.
// Icon → ExecutionStateCard+Icon.swift
// Attention → ExecutionStateCard+PresentationChrome+Attention.swift

extension ExecutionStateCard {
    var tint: Color {
        if let attention = tintAttention { return attention }
        switch state.kind {
        case .failed: return AtlasTheme.domOperacional
        case .replanning, .completed: return AtlasTheme.domAutonomos
        default: return AtlasTheme.accent
        }
    }
}
