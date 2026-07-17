import SwiftUI

/// Folha C11: mensagens enfileiradas durante execução — promover (enviar agora)
/// ou remover. Só renderiza o que `ConversationModel.queuedMessages` expõe.
/// Row → QueuedFollowUpRow.swift.
struct QueuedFollowUpsSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    var model: ConversationModel

    var body: some View {
        Group {
            if model.queuedMessages.isEmpty {
                Color.clear.onAppear { dismiss() }
            } else {
                sheetContent
            }
        }
        .accessibilityIdentifier(A11yID.queueSheet)
    }

    private var sheetContent: some View {
        let messages = model.queuedMessages
        let total = messages.count
        return SheetShell(title: sheetTitle(count: total)) {
            if total > 1 {
                Text("ordem da fila · a cabeça envia quando o turno terminar")
                    .font(.system(size: 12))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 10)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel(
                        "fila ordenada; a primeira mensagem envia quando o turno atual terminar"
                    )
            }
            ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                QueuedFollowUpRow(
                    message: message,
                    index: index,
                    total: total,
                    onPromote: { Task { await model.promote(id: message.id) } },
                    onRemove: { Task { await model.removeQueued(id: message.id) } }
                )
                .transition(reduceMotion ? .identity : .opacity)
            }
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: messages.map(\.id))
        }
    }

    private func sheetTitle(count: Int) -> String {
        count == 1 ? "Fila · 1" : "Fila · \(count)"
    }
}
