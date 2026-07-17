import SwiftUI
import AtlasCore

// Corpo tags/notas — peel de AutonomosTransferStatus.
// Tags → AutonomosFleetTransfer+Tags.swift
// Notes → AutonomosFleetTransfer+Notes.swift

extension AutonomosTransferStatus {
    var transferBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            transferTags
            transferNotes
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(transfer.transferSpokenSummary)
        .accessibilityAddTraits(transfer.isHandoffInFlight ? .updatesFrequently : [])
    }
}
