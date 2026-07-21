import SwiftUI
import AtlasCore

// Queue chip + labels — WAVE-006.

extension ConversationComposer {
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

    var queueChipLabel: String {
        let n = model.queuedMessages.count
        return n == 1 ? "Fila · 1" : "Fila · \(n)"
    }

    var queueAccessibilityLabel: String {
        let n = model.queuedMessages.count
        return n == 1
            ? "1 mensagem na fila durante a execução"
            : "\(n) mensagens na fila durante a execução"
    }
}
