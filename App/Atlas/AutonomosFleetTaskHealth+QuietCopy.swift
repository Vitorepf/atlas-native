import SwiftUI
import AtlasCore

// Quiet copy — peel de AutonomosFleetTaskHealth+QuietBody.

extension AutonomosTaskHealthSection {
    var quietCopy: some View {
        Text("estável · \(health.tasks.servableNow) servíveis · \(health.leases.active) leases")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
