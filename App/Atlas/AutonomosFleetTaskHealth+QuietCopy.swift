import SwiftUI
import AtlasCore

// Quiet copy — peel de AutonomosFleetTaskHealth+QuietBody.

extension AutonomosTaskHealthSection {
    var quietCopy: some View {
        Text("estável · \(health.tasks.servableNow) tarefa\(health.tasks.servableNow == 1 ? "" : "s") pronta\(health.tasks.servableNow == 1 ? "" : "s")\(health.leases.active > 0 ? " · \(health.leases.active) em execução" : "")")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}
