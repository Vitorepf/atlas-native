import SwiftUI
import AtlasCore

// Linha de conversa — compartilhada com Search/Workspace. Hub vivo: turno
// executando troca ícone por losango e contador por "executando".
// Content → RootChrome+ThreadRow+Content.swift
// A11y → RootChrome+ThreadRow+A11y.swift

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
