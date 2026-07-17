import SwiftUI
import AtlasCore

// Campos de placement verificado — peel de AutonomosTransferSheet (régua ≤100).
// Host → AutonomosTransferSheet+PlacementHost.swift · Repo → +PlacementRepo.swift
// Lease → AutonomosTransferSheet+PlacementLease.swift

extension AutonomosTransferSheet {
    @ViewBuilder
    var placementFields: some View {
        placementHostFields
        placementRepoFields
        placementLeaseFields
    }
}
