import SwiftUI
import AtlasCore

// Transfer status header — peel de AutonomosFleetTransfer.
// Status → AutonomosFleetTransfer+Header+Status.swift
// Refresh → AutonomosFleetTransfer+Header+Refresh.swift

extension AutonomosTransferStatus {
    var transferHeader: some View {
        HStack(spacing: 10) {
            transferHeaderStatus
            Spacer()
            transferHeaderRefresh
        }
    }
}
