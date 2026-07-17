import SwiftUI

/// Folha C11: mensagens enfileiradas durante execução — promover (enviar agora)
/// ou remover. Só renderiza o que `ConversationModel.queuedMessages` expõe.
struct QueuedFollowUpsSheet: View {
    var model: ConversationModel

    var body: some View {
        SheetShell(title: "Fila · \(model.queuedMessages.count)") {
            ForEach(model.queuedMessages) { m in
                HStack(spacing: 12) {
                    Text(m.text)
                        .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button { Task { await model.promote(id: m.id) } } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AtlasTheme.accent)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(AtlasTheme.goldVeil))
                    }
                    .buttonStyle(PressableScale())
                    .accessibilityLabel("enviar agora: \(m.text)")
                    Button { Task { await model.removeQueued(id: m.id) } } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(AtlasTheme.surfaceHi))
                    }
                    .buttonStyle(PressableScale())
                    .accessibilityLabel("remover da fila: \(m.text)")
                }
                .padding(.vertical, 6)
            }
        }
    }
}
