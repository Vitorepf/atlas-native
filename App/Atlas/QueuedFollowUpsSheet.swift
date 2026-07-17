import SwiftUI

/// Folha C11: mensagens enfileiradas durante execução — promover (enviar agora)
/// ou remover. Só renderiza o que `ConversationModel.queuedMessages` expõe.
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

// MARK: - Row (ordem = índice em `queuedMessages`, sem posição inventada)

private struct QueuedFollowUpRow: View {
    let message: QueuedMessage
    let index: Int
    let total: Int
    let onPromote: () -> Void
    let onRemove: () -> Void

    private var positionCaption: String {
        let ordinal = index + 1
        if ordinal == 1 { return "próxima na fila" }
        return "\(ordinal)ª na fila"
    }

    private var rowSpokenLabel: String {
        let ordinal = index + 1
        if total == 1 { return message.text }
        if ordinal == 1 { return "primeira na fila, \(total) no total. \(message.text)" }
        return "\(ordinal)ª de \(total) na fila. \(message.text)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if total > 1 {
                    Text(positionCaption)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(index == 0 ? AtlasTheme.accent : AtlasTheme.textTertiary)
                }
                Text(message.text)
                    .font(.system(.callout))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(rowSpokenLabel)

            Button(action: onPromote) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(AtlasTheme.goldVeil))
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(promoteLabel)
            .accessibilityHint(promoteHint)
            .accessibilityIdentifier(A11yID.queuePromote(message.id))

            Button(action: onRemove) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(AtlasTheme.surfaceHi))
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(removeLabel)
            .accessibilityHint(removeHint)
            .accessibilityIdentifier(A11yID.queueRemove(message.id))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .accessibilityIdentifier(A11yID.queueRow(index))
        .overlay(alignment: .bottom) {
            Divider().overlay(AtlasTheme.separator).padding(.leading, 24)
        }
    }

    private var promoteLabel: String {
        "enviar agora, \(positionCaption): \(message.text)"
    }

    private var promoteHint: String {
        "torna esta mensagem a próxima instrução; o turno atual continua"
    }

    private var removeLabel: String {
        "remover da fila, \(positionCaption): \(message.text)"
    }

    private var removeHint: String {
        "remove da fila sem enviar"
    }
}
