import SwiftUI
import AtlasCore

// Status capsule symbol — peel de AtlasCodeGraphChrome+StatusTokens.

extension AtlasCodeView {
    var statusCapsuleSymbol: String {
        switch model.scanState {
        case .violating: return "exclamationmark.triangle"
        case .clean: return "checkmark"
        case .unknown: return "questionmark"
        }
    }
}
