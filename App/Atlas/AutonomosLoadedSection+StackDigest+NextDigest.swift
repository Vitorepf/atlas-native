import SwiftUI
import AtlasCore

// Next digest — peel de AutonomosLoadedSection+StackDigest.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackNextDigest: some View {
        if let digest = model.digest {
            AutonomosDigestToggleLine(
                title: "governado",
                detail: "\(digest.last.counts.risks) risco\(digest.last.counts.risks == 1 ? "" : "s") · \(digest.last.counts.pendingDecisions) decisõ\(digest.last.counts.pendingDecisions == 1 ? "e" : "es")",
                expanded: $governedDigestExpanded,
                a11yID: A11yID.autonomosGovernedToggle
            )
            if governedDigestExpanded {
                AutonomosNextDigestSection(digest: digest)
            }
        }
    }
}
