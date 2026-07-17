import SwiftUI
import AtlasCore

// Milestone tags — peel de AutonomosTransferStatus body.
// Handoff → AutonomosFleetTransfer+TagsHandoff.swift
// Milestone → AutonomosFleetTransfer+TagsMilestone.swift

extension AutonomosTransferStatus {
    @ViewBuilder
    var transferTags: some View {
        transferHandoffTags
        transferMilestoneTags
    }
}
