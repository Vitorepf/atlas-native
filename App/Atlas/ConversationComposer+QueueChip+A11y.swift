import SwiftUI
import AtlasCore

// Queue chip a11y — peel de ConversationComposer+QueueGrabber.

extension ConversationComposer {
    @ViewBuilder
    func queueChipA11y<V: View>(_ button: V) -> some View {
        button
            .padding(.bottom, expanded ? 0 : 8)
            .transition(reduceMotion ? .identity : .opacity)
            .accessibilityLabel(queueAccessibilityLabel)
            .accessibilityHint("abre a folha para enviar agora ou remover da fila")
            .accessibilityIdentifier(A11yID.queueChip)
    }
}
