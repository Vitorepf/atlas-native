import SwiftUI
import AtlasCore

// Action fill colors — peel de ExecutionStateCard+ActionColors+Fill.

extension ExecutionStateActionStyle {
    var background: Color {
        switch style {
        case .primary: return AtlasTheme.accent
        case .secondary: return AtlasTheme.surfaceHi
        case .destructive: return AtlasTheme.domOperacional.opacity(0.2)
        }
    }
}
