import SwiftUI
import AtlasCore

// Chips + aging + findings — peel de AutonomosOperationDigestSection+Body.
// Aging → AutonomosOperationDigestSection+Aging.swift
// Chips → AutonomosOperationDigestSection+SignalChips.swift

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestSignalMeta: some View {
        digestSignalChips
        digestAgingFindings
    }
}
