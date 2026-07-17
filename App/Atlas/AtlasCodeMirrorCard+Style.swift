import AtlasCore
import SwiftUI

// Style + a11y helpers — peel de AtlasCodeMirrorCard.
// Label → AtlasCodeMirrorCard+StyleLabel.swift

extension AtlasCodeMirrorCard {
    var background: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.05) }
        return AtlasTheme.surface.opacity(0.4)
    }

    var borderColor: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.35) }
        return AtlasTheme.separator
    }
}
