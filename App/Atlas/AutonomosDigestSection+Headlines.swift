import SwiftUI
import AtlasCore

// Headlines — peel de AutonomosDigestSection+Predicates.

extension AutonomosNextDigestSection {
    func digestMergeTag(_ digest: AtlasAutonomosDigestResponse) -> String? {
        digest.last.delivered.first.map { String($0.mergeHash.prefix(8)) }
    }

    func digestRiskHeadline(_ digest: AtlasAutonomosDigestResponse) -> String? {
        digest.last.risks.first.flatMap { $0.title?.nonEmpty ?? $0.reason?.nonEmpty ?? $0.severity }
    }

    func digestDecisionHeadline(_ digest: AtlasAutonomosDigestResponse) -> String? {
        digest.last.pendingDecisions.first?.title
    }
}
