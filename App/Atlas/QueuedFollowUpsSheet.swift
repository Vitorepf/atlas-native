import SwiftUI

/// Folha C11: mensagens enfileiradas durante execução — promover (enviar agora)
/// ou remover. Só renderiza o que `ConversationModel.queuedMessages` expõe.
/// Content → QueuedFollowUpsSheet+Content.swift · Row → QueuedFollowUpRow.swift.
/// EmptyBranch → QueuedFollowUpsSheet+EmptyBranch.swift · A11yShell → +A11yShell.swift
struct QueuedFollowUpsSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dismiss) var dismiss

    var model: ConversationModel

    var body: some View {
        queueSheetA11yShell(queueSheetBodyBranch)
    }
}
