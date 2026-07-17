import SwiftUI
import AtlasCore

// Choice actions — peel de ExecutionStateCard.
// Steer/retry → ExecutionStateCard+SteerRetry.swift
// Choices → ExecutionStateCard+ActionChoices.swift

extension ExecutionStateCard {
    @ViewBuilder
    var actionButtons: some View {
        choiceActionButtons
        steerButton
    }
}
