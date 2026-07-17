import SwiftUI
import AtlasCore

// Finding card fields — peel de AutonomosDetailLedgerRows+Findings.
// Identity → AutonomosDetailLedgerRows+FindingFields+Identity.swift
// Risk/meta → AutonomosDetailLedgerRows+FindingFields+RiskMeta.swift

extension AutonomosDetailLedgerFindings {
    @ViewBuilder
    static func findingCardFields(_ item: AtlasAutonomosFinding) -> some View {
        findingIdentityFields(item)
        findingRiskMetaFields(item)
    }
}
