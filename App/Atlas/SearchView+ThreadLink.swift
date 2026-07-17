import SwiftUI
import AtlasCore

// Thread link — peel de SearchView+List.
// Spoken → SearchView+ThreadLinkSpoken.swift

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
}
