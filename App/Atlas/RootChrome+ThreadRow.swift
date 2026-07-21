import AtlasCore
import SwiftUI

// Cycle 041 fuse → RootChrome+ThreadRow.swift

extension ThreadRow {
    func threadA11yChrome<Content: View>(_ content: Content) -> some View {
        content
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

extension ThreadRow {
    var rowContent: some View {
        HStack(spacing: 14) {
            rowLead
            Text(thread.title).font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1).truncationMode(.tail)
                .accessibilityHidden(true)
            Spacer(minLength: 8)
            rowTrailing
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
        .overlay(alignment: .leading) { rowWorkspaceTint }
        .contentShape(Rectangle())
    }
}

extension ThreadRow {
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
}

extension ThreadRow {
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

extension ThreadRow {
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
}

extension ThreadRow {
    @ViewBuilder
    var rowTrailing: some View {
        rowTrailingStatus
        Image(systemName: "chevron.right")
            .atlasSans(13, .semibold).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    var rowTrailingCount: some View {
        Text("\(thread.messageCount)")
            .atlasSans(16)
            .foregroundStyle(AtlasTheme.textTertiary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowTrailingRunning: some View {
        Text("executando").font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
    }
}

extension ThreadRow {
    @ViewBuilder
    var rowTrailingStatus: some View {
        newThreadBadge
        if isRunning {
            rowTrailingRunning
        } else {
            rowTrailingCount
        }
    }
}

// Linha de conversa — compartilhada com Search/Workspace. Hub vivo: turno
// executando troca ícone por losango e contador por "executando".

struct ThreadRow: View {
    let thread: AtlasAiThread
    /// Sinal saturado não discrimina: quando a maioria da lista seria "novo",
    /// o dono da lista silencia o badge em bloco (volta quando for exceção).
    var newBadgeSuppressed: Bool = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isRunning: Bool { TurnPresence.shared.runningTitles.contains(thread.title) }
    var isNew: Bool { !newBadgeSuppressed && ConversationModel.hasNewerContent(thread) }
    var workspaceTint: Color? { thread.workspace.map(threadWorkspaceColor) }

    var body: some View {
        threadA11yChrome(rowContent)
    }
}

func threadWorkspaceColor(_ workspace: String) -> Color {
    let palette = [AtlasTheme.accent, AtlasTheme.prussian, AtlasTheme.domAutonomos, AtlasTheme.domOperacional]
    let total = workspace.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    return palette[abs(total) % palette.count]
}
