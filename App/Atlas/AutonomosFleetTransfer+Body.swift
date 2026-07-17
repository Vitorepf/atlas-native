import SwiftUI
import AtlasCore

// Corpo tags/notas — peel de AutonomosTransferStatus.
// Tags → AutonomosFleetTransfer+Tags.swift
// Notes → AutonomosFleetTransfer+Notes.swift
// A11y → AutonomosFleetTransfer+BodyA11y.swift

extension AutonomosTransferStatus {
    var transferBody: some View {
        transferBodyA11y(
            VStack(alignment: .leading, spacing: 8) {
                transferTags
                transferNotes
            }
        )
    }
}
