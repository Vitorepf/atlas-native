import SwiftUI
import AtlasCore

// Status chrome tokens — peel de AtlasCodeGraphChrome+Status.

extension AtlasCodeView {
    var statusCapsuleColor: Color {
        switch model.scanState {
        case .violating: return AtlasCodePalette.alert
        case .clean: return AtlasCodePalette.healed
        case .unknown: return AtlasTheme.textTertiary
        }
    }

    var statusCapsuleSymbol: String {
        switch model.scanState {
        case .violating: return "exclamationmark.triangle"
        case .clean: return "checkmark"
        case .unknown: return "questionmark"
        }
    }
}
