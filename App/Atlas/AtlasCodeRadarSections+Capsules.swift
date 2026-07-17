import SwiftUI
import AtlasCore

// Capsules silent/alarm — peel de AtlasCodeRadarStatusCapsule.

extension AtlasCodeRadarStatusCapsule {
    /// Caption baixa — mesmo padrão da frota («frota» / «fila») sem incidente.
    var silentCaption: some View {
        Text(model.scanState == .clean ? "código" : model.headline)
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.vertical, 7)
            .accessibilityHidden(true)
    }

    var alarmCapsule: some View {
        HStack(spacing: 7) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 10, weight: .semibold))
                .accessibilityHidden(true)
            Text(model.headline)
                .font(.system(size: 11, weight: .semibold))
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
