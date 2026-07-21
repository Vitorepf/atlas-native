import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: was RootChromeBody — file is ThreadRow only

// MARK: - Row host

struct ThreadRow: View {
    let thread: AtlasAiThread
    var newBadgeSuppressed: Bool = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) private var session

    /// WAVE-032: threadId-first running signal (title fallback only if no id).
    var isRunning: Bool {
        WorkspaceThreadJudgment.isRunning(
            thread: thread,
            remote: session.remoteLiveSessions
        )
    }
    var isNew: Bool { !newBadgeSuppressed && ConversationModel.hasNewerContent(thread) }
    var workspaceTint: Color? { thread.workspace.map(threadWorkspaceColor) }

    var body: some View {
        rowContent
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                WorkspaceThreadJudgment.threadSpoken(
                    title: thread.title,
                    messageCount: thread.messageCount,
                    isRunning: isRunning,
                    isNew: isNew,
                    hasWorkspace: workspaceTint != nil
                )
            )
            .accessibilityHint(WorkspaceThreadJudgment.threadHint(isRunning: isRunning))
    }

    var rowContent: some View {
        HStack(spacing: 14) {
            rowLead
            Text(thread.title).font(AtlasFont.serif(16)).foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1).truncationMode(.tail)
                .accessibilityHidden(true)
            Spacer(minLength: 8)
            rowTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .overlay(alignment: .leading) { rowWorkspaceTint }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    var rowLead: some View {
        if isRunning {
            BreathingDiamond(size: 9, reduceMotion: reduceMotion).frame(width: 22)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "bubble.left")
                .atlasSans(17).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    var rowWorkspaceTint: some View {
        if let workspaceTint {
            Rectangle()
                .fill(workspaceTint.opacity(0.85))
                .frame(width: 2)
                .padding(.vertical, 10)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    var rowTrailing: some View {
        newThreadBadge
        if isRunning {
            Text("executando").font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        } else {
            Text("\(thread.messageCount)")
                .atlasSans(16)
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
        Image(systemName: "chevron.right")
            .atlasSans(13, .semibold).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    var newThreadBadge: some View {
        if isNew && !isRunning {
            Text("novo")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Capsule().fill(AtlasTheme.goldVeil))
                .accessibilityHidden(true)
        }
    }
}
