import SwiftUI
import AtlasCore

// WAVE-152 density peel

extension ExecutionStateCard {
    func retryFallbackA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(ExecutionStateActionStyle(
                style: .primary,
                reduceMotion: reduceMotion
            ))
            .accessibilityIdentifier(A11yID.executionRetry)
            .accessibilityLabel(ExecutionStateCardJudgment.retryLabel)
            .accessibilityHint(ExecutionStateCardJudgment.retryHint)
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    func retryFallbackAction(_ jobId: JobID) -> some View {
        retryFallbackA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry(jobId)
            } label: {
                retryFallbackLabel
            }
        )
    }
}

extension ExecutionStateCard {
    var retryFallbackLabel: some View {
        Text("Retomar")
            .font(AtlasFont.mono(10, .semibold))
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }
}

extension ExecutionStateCard {
    var steerButtonLabel: some View {
        Text("Redirecionar")
            .font(.system(.caption, weight: .semibold))
            .lineLimit(1)
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var steerActionButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSteer?()
        } label: {
            steerButtonLabel
        }
        .buttonStyle(ExecutionStateActionStyle(
            style: .secondary,
            reduceMotion: reduceMotion
        ))
        .accessibilityLabel(ConversationLiveStripJudgment.spokenSteer())
        .accessibilityHint(ConversationLiveStripJudgment.spokenSteerHint())
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var steerButton: some View {
        if onSteer != nil {
            steerActionButton
        }
    }
}

extension ExecutionStateCard {
    var frozenTimerText: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        guard ExecutionStateCardJudgment.freezesTimer(for: state.kind) else { return nil }
        return "‖ \(Self.clock(timer.elapsedActiveMilliseconds))"
    }
}

extension ExecutionStateCard {
    var frozenTimerA11y: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        guard ExecutionStateCardJudgment.freezesTimer(for: state.kind) else { return nil }
        return "tempo ativo congelado em \(Self.clock(timer.elapsedActiveMilliseconds))"
    }
}

extension ExecutionStateCard {
    var recoveringTimerText: String? {
        guard state.kind == .recovering, let timer = state.timer else { return nil }
        return "ativo \(Self.clock(timer.elapsedActiveMilliseconds))"
    }

    var spokenTimerFragment: String? {
        frozenTimerA11y ?? recoveringTimerText
    }
}
