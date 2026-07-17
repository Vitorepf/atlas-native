import SwiftUI
import AtlasCore

// Trailing control (enviar / processando / menu) — peel de ComposerToolbar.

extension ComposerToolbar {
    // Contexto fica atrás de uma única ação real. O modo, o esforço e o
    // workspace continuam disponíveis, sem disputar a atenção da escrita.
    @ViewBuilder var trailingControl: some View {
        if canSubmit {
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 29))
                    .foregroundStyle(AtlasTheme.accent)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: .command)
            .accessibilityLabel(spokenSendLabel(canSubmit: true))
            .accessibilityHint(spokenSendHint(canSubmit: true))
            .accessibilityIdentifier(A11yID.conversationSend)
        } else if isExecuting {
            ZStack {
                BreathingDiamond(size: 13, reduceMotion: reduceMotion)
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 29))
                    .foregroundStyle(AtlasTheme.textTertiary.opacity(0.38))
            }
            .frame(width: 32, height: 32)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(spokenProcessingLabel()), \(spokenSendLabel(canSubmit: false))")
            .accessibilityHint(spokenSendHint(canSubmit: false))
            .accessibilityIdentifier(A11yID.conversationSend)
        } else {
            Menu {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    onShowWorkspace()
                } label: {
                    Label("Workspace: \(model.workspaceName ?? "Atlas")", systemImage: "square.grid.2x2")
                }
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    onShowMode()
                } label: {
                    Label("Modo: \(mode.capitalized)", systemImage: "slider.horizontal.3")
                }
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    onShowEffort()
                } label: {
                    Label("Esforço: \(model.effort.shortLabel)", systemImage: "gauge.with.dots.needle.33percent")
                }
                .accessibilityLabel(spokenEffortLabel(model.effort))
                .accessibilityHint("abre opções de esforço computacional")
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
            }
            .accessibilityLabel("opções da conversa")
            .accessibilityHint(spokenOptionsHint())
            .accessibilityIdentifier(A11yID.conversationOptions)
        }
    }
}
