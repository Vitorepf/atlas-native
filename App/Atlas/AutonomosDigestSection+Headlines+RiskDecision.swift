import SwiftUI
import AtlasCore

// Risk + decision headlines — peel de AutonomosDigestSection+Headlines.

extension AutonomosNextDigestSection {
    func digestRiskHeadline(_ digest: AtlasAutonomosDigestResponse) -> String? {
        digest.last.risks.first.flatMap { $0.title?.nonEmpty ?? $0.reason?.nonEmpty ?? $0.severity }
    }

    func digestDecisionHeadline(_ digest: AtlasAutonomosDigestResponse) -> String? {
        digest.last.pendingDecisions.first?.title
    }
}
