import SwiftUI
import AtlasCore

// Last digest risk/decision — peel de AutonomosDigestSection+Last.
// RiskLine → AutonomosDigestSection+LastRisk+RiskLine.swift
// DecisionLine → AutonomosDigestSection+LastRisk+DecisionLine.swift

extension AutonomosNextDigestSection {
    @ViewBuilder
    func lastDigestRiskDecision(_ digest: AtlasAutonomosDigestResponse) -> some View {
        if let risk = digest.last.risks.first {
            lastDigestRiskLine(risk)
        }
        if let decision = digest.last.pendingDecisions.first {
            lastDigestDecisionLine(decision)
        }
    }
}
