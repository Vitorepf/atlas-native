import SwiftUI
import AtlasCore

// Submit toolbar item — peel de SteerInteractionSheet+Toolbar.
// Button → SteerInteractionSheet+ToolbarSubmitButton.swift

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerSubmitItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            steerSubmitButton
        }
    }
}
