import SwiftUI
import AtlasCore

// Node state colors — peel de AtlasCodePalette.
// Healthy → AtlasCodePalette+Color+Healthy.swift

extension AtlasCodePalette {
    static func color(for state: AtlasCodeNodeState) -> Color {
        if let healthy = colorHealthy(for: state) { return healthy }
        switch state {
        case .violating: return alert
        case .history: return history
        default: return history
        }
    }
}
