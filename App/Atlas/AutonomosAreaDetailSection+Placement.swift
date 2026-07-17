import SwiftUI
import AtlasCore

// Placement block — peel de AutonomosAreaDetailSection.

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
                HStack(spacing: 8) {
                    if let host = p.host { AutonomosChrome.tag(host) }
                    if let env = p.environment { AutonomosChrome.tag(env) }
                    if let ws = p.workspace { AutonomosChrome.tag(ws) }
                    if let repo = p.repository { AutonomosChrome.tag(repo) }
                    if let branch = p.branch { AutonomosChrome.tag(branch) }
                    if let ttl = p.leaseTTLSeconds { AutonomosChrome.tag("lease \(ttl)s") }
                }
                .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AutonomosAreaDetailA11y.spokenPlacement(p))
        }
    }
}
