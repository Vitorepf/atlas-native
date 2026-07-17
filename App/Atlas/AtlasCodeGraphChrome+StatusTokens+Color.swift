import SwiftUI
import AtlasCore

// Status capsule color — peel de AtlasCodeGraphChrome+StatusTokens.

extension AtlasCodeView {
    var statusCapsuleColor: Color {
        switch model.scanState {
        case .violating: return AtlasCodePalette.alert
        case .clean: return AtlasCodePalette.healed
        case .unknown: return AtlasTheme.textTertiary
        }
    }
}
