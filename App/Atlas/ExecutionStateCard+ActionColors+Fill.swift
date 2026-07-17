import SwiftUI
import AtlasCore

// Fill colors — peel de ExecutionStateCard+ActionColors.
// Background → ExecutionStateCard+ActionColors+Fill+Background.swift

extension ExecutionStateActionStyle {
    var foreground: Color {
        style == .primary ? AtlasTheme.bg : AtlasTheme.textPrimary
    }
}
