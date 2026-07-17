import SwiftUI
import AtlasCore

// Steer + retry — peel de ExecutionStateCard+ActionButtons.

extension ExecutionStateCard {
    @ViewBuilder
    var retryFallbackButton: some View {
        if showsRetryFallback, let retryableJobId {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry(retryableJobId)
            } label: {
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
    }

    @ViewBuilder
    var steerButton: some View {
        if let onSteer {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onSteer()
            } label: {
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
            .accessibilityHint("abre instrução para o próximo checkpoint seguro")
        }
    }
}
