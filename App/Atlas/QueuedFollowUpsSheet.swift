import SwiftUI

/// Folha C11: mensagens enfileiradas durante execução — promover (enviar agora)
/// ou remover. Só renderiza o que `ConversationModel.queuedMessages` expõe.
/// Content → QueuedFollowUpsSheet+Content.swift · Row → QueuedFollowUpRow.swift.
/// EmptyDismiss → QueuedFollowUpsSheet+EmptyDismiss.swift
struct QueuedFollowUpsSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dismiss) private var dismiss

    var model: ConversationModel

    var body: some View {
        Group {
            if model.queuedMessages.isEmpty {
                emptyQueueDismiss
            } else {
                sheetContent
            }
        }
        .accessibilityIdentifier(A11yID.queueSheet)
        .accessibilityLabel(spokenQueueSheetLabel())
        .accessibilityHint("promover ou remover só mensagens reais da fila do model")
    }
}
