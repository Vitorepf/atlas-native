import SwiftUI
import AtlasCore

// Action style colors — peel de ExecutionStateCard+Actions.

extension ExecutionStateActionStyle {
    var background: Color {
        switch style {
        case .primary: return AtlasTheme.accent
        case .secondary: return AtlasTheme.surfaceHi
        case .destructive: return AtlasTheme.domOperacional.opacity(0.2)
        }
    }

    var foreground: Color {
        style == .primary ? AtlasTheme.bg : AtlasTheme.textPrimary
    }

    var border: Color {
        style == .destructive ? AtlasTheme.domOperacional.opacity(0.55) : AtlasTheme.separator
    }
}
