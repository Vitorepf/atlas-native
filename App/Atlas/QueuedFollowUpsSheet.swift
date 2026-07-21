import AtlasCore
import SwiftUI

// Cycle 043 fuse → QueuedFollowUpsSheet.swift

/// Folha C11: mensagens enfileiradas durante execução — promover (enviar agora)
/// ou remover. Só renderiza o que `ConversationModel.queuedMessages` expõe.
struct QueuedFollowUpsSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dismiss) var dismiss

    var model: ConversationModel

    var body: some View {
        queueSheetA11yShell(queueSheetBodyBranch)
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    func queueMessageRows(messages: [QueuedMessage]) -> some View {
        let total = messages.count
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

extension QueuedFollowUpsSheet {
    var sheetContent: some View {
        let messages = model.queuedMessages
        let total = messages.count
        return SheetShell(title: sheetTitle(count: total)) {
            queueOrderCaption(total: total)
            queueMessageRows(messages: messages)
        }
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    func queueOrderCaption(total: Int) -> some View {
        if total > 1 {
            Text("ordem da fila · a cabeça envia quando o turno terminar")
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(
                    "fila ordenada; a primeira mensagem envia quando o turno atual terminar"
                )
        }
    }
}

extension QueuedFollowUpsSheet {
    func queueSheetA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.queueSheet)
            // Contain without fused sheet label so queue rows stay focusable.
            .accessibilityElement(children: .contain)
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    var queueSheetBodyBranch: some View {
        if model.queuedMessages.isEmpty {
            emptyQueueDismiss
        } else {
            sheetContent
        }
    }
}

extension QueuedFollowUpsSheet {
    var emptyQueueDismiss: some View {
        Color.clear.onAppear { dismiss() }
    }
}

extension QueuedFollowUpsSheet {
    func sheetTitle(count: Int) -> String {
        count == 1 ? "Fila · 1" : "Fila · \(count)"
    }
}


// Cycle 043 fuse → QueuedFollowUpRow.swift

struct QueuedFollowUpRow: View {
    let message: QueuedMessage
    let index: Int
    let total: Int
    let onPromote: () -> Void
    let onRemove: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        rowLayout
    }
}

extension QueuedFollowUpRow {
    var promoteLabel: String { "enviar agora, \(positionCaption): \(message.text)" }
    var promoteHint: String { "torna esta mensagem a próxima instrução; o turno atual continua" }
    var removeLabel: String { "remover da fila, \(positionCaption): \(message.text)" }
    var removeHint: String { "remove da fila sem enviar" }
}

extension QueuedFollowUpRow {
    var positionCaption: String {
        let ordinal = index + 1
        if ordinal == 1 { return "próxima na fila" }
        return "\(ordinal)ª na fila"
    }

    var rowSpokenLabel: String {
        let ordinal = index + 1
        if total == 1 { return message.text }
        if ordinal == 1 { return "primeira na fila, \(total) no total. \(message.text)" }
        return "\(ordinal)ª de \(total) na fila. \(message.text)"
    }
}

extension QueuedFollowUpRow {
    var promoteButton: some View {
        Button {
            // Medium: promote commits the next instruction (send class).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onPromote()
        } label: {
            Image(systemName: "arrow.up")
                .atlasSans(15, .semibold)
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 44, height: 44)
                .background(Circle().fill(AtlasTheme.goldVeil))
                .contentShape(Circle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(promoteLabel)
        .accessibilityHint(promoteHint)
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(8) // promote is send-class
        .accessibilityIdentifier(A11yID.queuePromote(message.id))
    }
}

extension QueuedFollowUpRow {
    var rowLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            rowText
            promoteButton
            removeButton
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .frame(minHeight: 56, alignment: .center)
        .contentShape(Rectangle())
        .accessibilityIdentifier(A11yID.queueRow(index))
        .overlay(alignment: .bottom) {
            Divider().overlay(AtlasTheme.separator).padding(.leading, 24)
                .accessibilityHidden(true)
        }
    }
}

extension QueuedFollowUpRow {
    var removeButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRemove()
        } label: {
            Image(systemName: "trash")
                .atlasSans(14)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(AtlasTheme.surfaceHi))
                .contentShape(Circle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(removeLabel)
        .accessibilityHint(removeHint)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.queueRemove(message.id))
    }
}

extension QueuedFollowUpRow {
    var rowMessagePreview: some View {
        Text(message.text)
            .font(.system(.callout))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}

extension QueuedFollowUpRow {
    @ViewBuilder
    var rowPositionCaption: some View {
        if total > 1 {
            Text(positionCaption)
                .font(AtlasFont.mono(10))
                .foregroundStyle(index == 0 ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension QueuedFollowUpRow {
    var rowText: some View {
        VStack(alignment: .leading, spacing: 4) {
            rowPositionCaption
            rowMessagePreview
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowSpokenLabel)
    }
}
