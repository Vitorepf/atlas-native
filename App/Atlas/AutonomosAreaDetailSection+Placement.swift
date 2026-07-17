import SwiftUI
import AtlasCore

// Placement block — peel de AutonomosAreaDetailSection.
// Tags → AutonomosAreaDetailSection+PlacementTags.swift

extension AutonomosAreaDetailSection {
    /// C13: placement é só o rótulo verificado do lock real — campo ausente
    /// permanece ausente, sem fallback visual.
    @ViewBuilder
    var placementSection: some View {
        if let p = model.live?.runtimePlacement,
           p.host != nil || p.workspace != nil || p.repository != nil {
            VStack(alignment: .leading, spacing: 5) {
                Text("ONDE ESTÁ RODANDO").font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                placementTags(p)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosAreaDetailA11y.spokenPlacement(p))
        }
    }
}
