import SwiftUI
import AtlasCore

// Operator sections — peel de AutonomosTransferSheet+Form.
// Target → AutonomosTransferSheet+Operator+Target.swift
// Actor → AutonomosTransferSheet+Operator+Actor.swift
// Reason → AutonomosTransferSheet+Operator+Reason.swift

extension AutonomosTransferSheet {
    @ViewBuilder
    var transferOperatorSections: some View {
        transferOperatorTargetSection
        transferOperatorActorSection
        transferOperatorReasonSection
    }
}
