import SwiftUI
import AtlasCore

// Aging + findings do digest — peel de AutonomosOperationDigestSection+SignalMeta.
// Oldest → AutonomosOperationDigestSection+Aging+Oldest.swift
// Findings → AutonomosOperationDigestSection+Aging+Findings.swift

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestAgingFindings: some View {
        digestOldestBacklog
        digestFindingsByRisk
    }
}
