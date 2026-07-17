import SwiftUI
import AtlasCore

// Thread link — peel de SearchView+List.

struct SearchThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool

    var body: some View {
        NavigationLink(value: Route.thread(id: ThreadID(thread.id), title: thread.title)) {
            ThreadRow(thread: thread)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(SearchThreadLink.spokenLabel(thread))
        .accessibilityHint("abre a conversa")
        .accessibilityIdentifier(A11yID.searchResult(thread.id))
        .transition(reduceMotion ? .opacity : .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 6)),
            removal: .opacity
        ))
    }

    static func spokenLabel(_ thread: AtlasAiThread) -> String {
        var parts = [thread.title, "\(thread.messageCount) mensagens"]
        if TurnPresence.shared.runningTitles.contains(thread.title) {
            parts.append("executando")
        } else if ConversationModel.hasNewerContent(thread) {
            parts.append("novo desde a última visita")
        }
        return parts.joined(separator: ", ")
    }
}
