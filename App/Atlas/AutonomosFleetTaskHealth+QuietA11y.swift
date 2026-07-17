import SwiftUI
import AtlasCore

// Quiet a11y — peel de AutonomosFleetTaskHealth+QuietBody.

extension AutonomosTaskHealthSection {
    func quietA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                AutonomosTaskHealthA11y.spokenQuiet(
                    servableNow: health.tasks.servableNow,
                    activeLeases: health.leases.active
                )
            )
            .accessibilityIdentifier(A11yID.autonomosTaskHealthQuiet)
    }
}
