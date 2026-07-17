import SwiftUI
import AtlasCore

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
                    .accessibilityHint("ação declarada pelo servidor")
                }
            }
        } else if showsRetryFallback, let retryableJobId {
            Button { onRetry(retryableJobId) } label: {
                Text("Retomar")
                    .font(.system(.caption, weight: .semibold))
                    .padding(.horizontal, 11).padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ExecutionStateActionStyle(
                style: .primary,
                reduceMotion: reduceMotion
            ))
            .accessibilityLabel("retomar execução a partir do último checkpoint")
            .accessibilityHint("reenfileira o job que falhou")
        }
        if let onSteer {
            Button(action: onSteer) {
                Text("Redirecionar")
                    .font(.system(.caption, weight: .semibold))
                    .lineLimit(1)
                    .padding(.horizontal, 11).padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ExecutionStateActionStyle(
                style: .secondary,
                reduceMotion: reduceMotion
            ))
            .accessibilityLabel("redirecionar esta execução")
        }
    }
}
