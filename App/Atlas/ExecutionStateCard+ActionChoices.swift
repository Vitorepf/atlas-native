import SwiftUI
import AtlasCore

// Choice action buttons — peel de ExecutionStateCard+ActionButtons.
// Stack → ExecutionStateCard+ActionChoicesStack.swift

extension ExecutionStateCard {
    @ViewBuilder
    var choiceActionButtons: some View {
        if effectiveChoiceJobId != nil, !state.actions.isEmpty {
            choiceButtonsStack
        } else {
            retryFallbackButton
        }
    }
}
