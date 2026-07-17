import SwiftUI
import AtlasCore

// Quiet caption — peel de AutonomosFleetSection+Body.

extension AutonomosFleetSection {
    @ViewBuilder
    var fleetQuietCaption: some View {
        if isQuiet && !auditModeEnabled {
            Text("todos vivos · desejados · autorizados")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
