import SwiftUI
import AtlasCore

// Linha de conversa — compartilhada com Search/Workspace. Hub vivo: turno
// executando troca ícone por losango e contador por "executando".
// Content → RootChrome+ThreadRow+Content.swift
// A11y → RootChrome+ThreadRow+A11y.swift

struct ThreadRow: View {
    let thread: AtlasAiThread
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isRunning: Bool { TurnPresence.shared.runningTitles.contains(thread.title) }
    var isNew: Bool { ConversationModel.hasNewerContent(thread) }
    var workspaceTint: Color? { thread.workspace.map(threadWorkspaceColor) }

    var body: some View {
        threadA11yChrome(rowContent)
    }
}
