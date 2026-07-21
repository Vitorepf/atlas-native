import SwiftUI
import AtlasCore

// Border color — peel de ExecutionStateCard+ActionColors.

extension ExecutionStateActionStyle {
    var border: Color {
        style == .destructive ? AtlasTheme.domOperacional.opacity(0.55) : AtlasTheme.separator
    }
}
