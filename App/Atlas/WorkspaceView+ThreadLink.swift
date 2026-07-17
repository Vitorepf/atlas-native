import SwiftUI
import AtlasCore

struct WorkspaceThreadLink: View {
    let thread: AtlasAiThread
    let reduceMotion: Bool

    var body: some View {
        NavigationLink(value: Route.thread(id: ThreadID(thread.id), title: thread.title)) {
            ThreadRow(thread: thread)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(SearchThreadLink.spokenLabel(thread))
        .accessibilityHint("abre a conversa")
        .accessibilityIdentifier(A11yID.workspaceThread(thread.id))
        .transition(threadTransition)
    }
}
