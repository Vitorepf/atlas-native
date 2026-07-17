import SwiftUI
import AtlasCore

// Choice actions — peel de ExecutionStateCard.
// Steer/retry → ExecutionStateCard+SteerRetry.swift

extension ExecutionStateCard {
    @ViewBuilder
    var actionButtons: some View {
        if let choiceJobId = effectiveChoiceJobId, !state.actions.isEmpty {
            HStack(spacing: 8) {
                ForEach(state.actions) { action in
                    Button { onChoose(choiceJobId, action.id) } label: {
                        Text(action.title)
                            .font(.system(.caption, weight: .semibold))
                            .lineLimit(1)
                            .padding(.horizontal, 11).padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ExecutionStateActionStyle(
                        style: action.style,
                        reduceMotion: reduceMotion
                    ))
                    .accessibilityLabel(action.title)
                    .accessibilityHint("ação declarada pelo servidor")
                }
            }
        } else {
            retryFallbackButton
        }
        steerButton
    }
}
