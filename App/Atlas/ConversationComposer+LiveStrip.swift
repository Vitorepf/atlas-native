import SwiftUI
import AtlasCore

// Faixa de execução viva + fila — peel de ConversationComposer.

extension ConversationComposer {
    @ViewBuilder
    var liveExecutionSection: some View {
        if let live = liveBubble {
            ExecutingStrip(
                bubble: live,
                reduceMotion: reduceMotion,
                onStop: { model.cancel() },
                onSteer: live.traceId.map { trace in { steerTrace = ConversationSteerTraceRef(id: trace) } }
            )
                .padding(.top, expanded ? 0 : 4)
                .padding(.bottom, expanded ? 0 : 8)
                .transition(.opacity)
            Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
                .padding(.bottom, expanded ? 0 : 8)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    var queueChipSection: some View {
        if !model.queuedMessages.isEmpty {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                showQueueSheet = true
            } label: {
                Text(queueChipLabel)
                    .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(Capsule().fill(AtlasTheme.goldVeil)
                        .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
            }
            .buttonStyle(PressableScale())
            .padding(.bottom, expanded ? 0 : 8)
            .transition(reduceMotion ? .identity : .opacity)
            .accessibilityLabel(queueAccessibilityLabel)
            .accessibilityHint("abre a folha para enviar agora ou remover da fila")
            .accessibilityIdentifier(A11yID.queueChip)
        }
    }

    @ViewBuilder
    var keyboardGrabber: some View {
        if focused.wrappedValue {
            RoundedRectangle(cornerRadius: 3)
                .fill(AtlasTheme.textTertiary.opacity(0.55))
                .frame(width: 42, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .contentShape(Rectangle())
                .onTapGesture { dismissKeyboard() }
                .gesture(
                    DragGesture(minimumDistance: 6)
                        .onEnded { if $0.translation.height > 8 { dismissKeyboard() } }
                )
                .accessibilityLabel("fechar teclado")
                .accessibilityHint("toque ou arraste para baixo para dispensar o teclado")
                .accessibilityAddTraits(.isButton)
        }
    }
}
