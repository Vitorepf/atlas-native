import SwiftUI
import AtlasCore

// Transfer confirm toolbar item — peel de AutonomosTransferSheet+Toolbar.
// Button → AutonomosTransferSheet+ToolbarConfirm+Button.swift
// A11y → AutonomosTransferSheet+ToolbarConfirm+A11y.swift

extension AutonomosTransferSheet {
    @ToolbarContentBuilder
    var transferConfirmItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            transferConfirmA11y(transferConfirmButton)
        }
    }
}
