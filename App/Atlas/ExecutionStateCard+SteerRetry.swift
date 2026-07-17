import SwiftUI
import AtlasCore

// Steer — peel de ExecutionStateCard+ActionButtons.
// Button → ExecutionStateCard+SteerRetry+Button.swift

extension ExecutionStateCard {
    @ViewBuilder
    var steerButton: some View {
        if onSteer != nil {
            steerActionButton
        }
    }
}
