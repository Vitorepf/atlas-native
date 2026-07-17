import SwiftUI
import AtlasCore

// Toolbar steer — peel de SteerInteractionSheet.
// Submit → SteerInteractionSheet+ToolbarSubmit.swift
// Cancel → SteerInteractionSheet+ToolbarCancel.swift

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerToolbar: some ToolbarContent {
        steerCancelItem
        steerSubmitItem
    }
}
