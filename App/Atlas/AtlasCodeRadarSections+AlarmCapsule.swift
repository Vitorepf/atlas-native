import SwiftUI
import AtlasCore

// Alarm capsule — peel de AtlasCodeRadarSections+Capsules.

extension AtlasCodeRadarStatusCapsule {
    var alarmCapsule: some View {
        HStack(spacing: 7) {
            Image(systemName: "exclamationmark.triangle")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text(model.headline)
                .atlasSans(11, .semibold)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasCodePalette.alert)
        .padding(.horizontal, 15)
        .padding(.vertical, 7)
        .background(Capsule().fill(AtlasCodePalette.alert.opacity(0.09)))
        .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.35), lineWidth: 1))
    }
}
