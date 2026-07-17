import SwiftUI
import AtlasCore

// Node state colors — peel de AtlasCodePalette.

extension AtlasCodePalette {
    static func color(for state: AtlasCodeNodeState) -> Color {
        switch state {
        case .onMain: return onMain
        case .violating: return alert
        case .healed: return healed
        case .history: return history
        }
    }
}
