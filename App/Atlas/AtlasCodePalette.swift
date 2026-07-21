import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

// --- AtlasCodePalette+Color+Healthy.swift ---
extension AtlasCodePalette {
    static func colorHealthy(for state: AtlasCodeNodeState) -> Color? {
        switch state {
        case .onMain: return onMain
        case .healed: return healed
        default: return nil
        }
    }
}

// --- AtlasCodePalette+Color.swift ---
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

// --- AtlasCodePalette.swift ---
enum AtlasCodePalette {
    static let onMain = AtlasTheme.accent
    static let alert = Color(hex: 0xE08C8C)
    static let healed = Color(hex: 0x83B46D)
    static let history = Color(hex: 0x647682)
}
