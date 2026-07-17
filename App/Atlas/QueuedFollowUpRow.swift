import SwiftUI

struct QueuedFollowUpRow: View {
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
                        .accessibilityHidden(true)
                }
                Text(message.text)
                    .font(.system(.callout))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
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
                .accessibilityHidden(true)
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
