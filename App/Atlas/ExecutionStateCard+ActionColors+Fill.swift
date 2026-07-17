import SwiftUI
import AtlasCore

// Fill colors — peel de ExecutionStateCard+ActionColors.

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
}
