import SwiftUI
import AtlasCore

// Capsules silent/alarm — peel de AtlasCodeRadarStatusCapsule.
// Alarm → AtlasCodeRadarSections+AlarmCapsule.swift

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
}
