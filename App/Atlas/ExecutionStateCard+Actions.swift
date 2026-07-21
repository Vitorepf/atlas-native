import SwiftUI
import AtlasCore

// Action buttons, style, choices, steer, retry. Cycle 020 fuse.

extension ExecutionStateCard {
    @ViewBuilder
    var actionButtons: some View {
        choiceActionButtons
        steerButton
    }

    @ViewBuilder
    var choiceActionButtons: some View {
        if effectiveChoiceJobId != nil, !state.actions.isEmpty {
            choiceButtonsStack
        } else {
            retryFallbackButton
        }
    }

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

    func choiceActionButton(_ action: AtlasExecutionPresentationState.Action, choiceJobId: JobID) -> some View {
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
        .accessibilityIdentifier(A11yID.executionActionChoice(action.id))
        .accessibilityLabel(action.title)
        .accessibilityHint("ação declarada pelo servidor")
    }

    @ViewBuilder
    var retryFallbackButton: some View {
        if showsRetryFallback, let retryableJobId {
            retryFallbackAction(retryableJobId)
        }
    }

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

    func retryFallbackA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(ExecutionStateActionStyle(
                style: .primary,
                reduceMotion: reduceMotion
            ))
            .accessibilityIdentifier(A11yID.executionRetry)
            .accessibilityLabel("retomar execução a partir do último checkpoint")
            .accessibilityHint("reenfileira o job que falhou")
    }

    var retryFallbackLabel: some View {
        Text("Retomar")
            .font(.system(.caption, weight: .semibold))
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    var steerButton: some View {
        if onSteer != nil {
            steerActionButton
        }
    }

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
        .accessibilityLabel("redirecionar esta execução")
        .accessibilityHint("abre instrução para o próximo checkpoint seguro")
    }

    var steerButtonLabel: some View {
        Text("Redirecionar")
            .font(.system(.caption, weight: .semibold))
            .lineLimit(1)
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }
}

/// Estilo dos botões de ação do ExecutionStateCard.
struct ExecutionStateActionStyle: ButtonStyle {
    let style: AtlasExecutionPresentationState.ActionStyle
    var reduceMotion: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(Capsule().fill(background.opacity(configuration.isPressed ? 0.72 : 1)))
            .overlay(Capsule().stroke(border, lineWidth: 1))
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(
                reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct),
                value: configuration.isPressed
            )
    }

    var border: Color {
        style == .destructive ? AtlasTheme.domOperacional.opacity(0.55) : AtlasTheme.separator
    }

    var background: Color {
        switch style {
        case .primary: return AtlasTheme.accent
        case .secondary: return AtlasTheme.surfaceHi
        case .destructive: return AtlasTheme.domOperacional.opacity(0.2)
        }
    }

    var foreground: Color {
        style == .primary ? AtlasTheme.bg : AtlasTheme.textPrimary
    }
}
