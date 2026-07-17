import SwiftUI
import AtlasCore

// Healthy node colors — peel de AtlasCodePalette+Color.

extension AtlasCodePalette {
    static func colorHealthy(for state: AtlasCodeNodeState) -> Color? {
        switch state {
        case .onMain: return onMain
        case .healed: return healed
        default: return nil
        }
    }
}
