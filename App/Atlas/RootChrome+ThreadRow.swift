import SwiftUI
import AtlasCore

// Linha de conversa — compartilhada com Search/Workspace. Hub vivo: turno
// executando troca ícone por losango e contador por "executando".

struct ThreadRow: View {
    let thread: AtlasAiThread
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isRunning: Bool { TurnPresence.shared.runningTitles.contains(thread.title) }
    private var isNew: Bool { ConversationModel.hasNewerContent(thread) }
    private var workspaceTint: Color? { thread.workspace.map(threadWorkspaceColor) }

    var body: some View {
        HStack(spacing: 14) {
            if isRunning {
                BreathingDiamond(size: 9, reduceMotion: reduceMotion).frame(width: 22)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "bubble.left")
                    .font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                    .accessibilityHidden(true)
            }
            Text(thread.title).font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1).truncationMode(.tail)
                .accessibilityHidden(true)
            Spacer(minLength: 8)
            if isNew && !isRunning {
                Text("novo")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(AtlasTheme.goldVeil))
                    .accessibilityHidden(true)
            }
            if isRunning {
                Text("executando").font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
            } else {
                Text("\(thread.messageCount)")
                    .font(.system(size: 16))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                    .accessibilityHidden(true)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .overlay(alignment: .leading) {
            if let workspaceTint {
                Rectangle()
                    .fill(workspaceTint.opacity(0.85))
                    .frame(width: 2)
                    .padding(.vertical, 10)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            RootChromeRowA11y.threadSpoken(
                title: thread.title,
                messageCount: thread.messageCount,
                isRunning: isRunning,
                isNew: isNew,
                hasWorkspace: workspaceTint != nil
            )
        )
        .accessibilityHint(RootChromeRowA11y.threadHint(isRunning: isRunning))
    }
}
