import SwiftUI
import AtlasCore

// Queue chip — peel de ConversationComposer+LiveStrip.
// Grabber → ConversationComposer+KeyboardGrabber.swift
// Label → ConversationComposer+QueueChipLabel.swift

extension ConversationComposer {
    @ViewBuilder
    var queueChipSection: some View {
        if !model.queuedMessages.isEmpty {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                showQueueSheet = true
            } label: {
                queueChipLabelView
            }
            .buttonStyle(PressableScale())
            .padding(.bottom, expanded ? 0 : 8)
            .transition(reduceMotion ? .identity : .opacity)
            .accessibilityLabel(queueAccessibilityLabel)
            .accessibilityHint("abre a folha para enviar agora ou remover da fila")
            .accessibilityIdentifier(A11yID.queueChip)
        }
    }
}
