import SwiftUI
import AtlasCore

// Choice buttons stack — peel de ExecutionStateCard+ActionChoices.
// Button → ExecutionStateCard+ActionChoiceButton.swift

extension ExecutionStateCard {
    @ViewBuilder
    var choiceButtonsStack: some View {
        if let choiceJobId = effectiveChoiceJobId, !state.actions.isEmpty {
            HStack(spacing: 8) {
                ForEach(state.actions) { action in
                    choiceActionButton(action, choiceJobId: choiceJobId)
                }
            }
        }
    }
}
