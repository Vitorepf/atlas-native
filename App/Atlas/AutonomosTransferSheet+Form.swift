import SwiftUI
import AtlasCore

// Form sections — peel de AutonomosTransferSheet (régua ≤100).
// Operator → AutonomosTransferSheet+Operator.swift
// Lock → AutonomosTransferSheet+FormLock.swift

extension AutonomosTransferSheet {
    @ViewBuilder
    var transferForm: some View {
        Form {
            Section("Missão (preservada)") {
                Text(areaName)
                    .accessibilityLabel(AutonomosTransferSheetA11y.spokenMission(areaName))
                Text(focus).font(AtlasFont.mono(11)).foregroundStyle(.secondary)
                    .accessibilityLabel(AutonomosTransferSheetA11y.spokenFocus(focus))
            }
            transferLockSection
            if hasPlacement {
                transferOperatorSections
            }
        }
    }
}
