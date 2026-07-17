import SwiftUI
import AtlasCore

// Transition — peel de SearchView+ThreadLink.

extension SearchThreadLink {
    func threadLinkTransition<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(SearchThreadLink.spokenLabel(thread))
            .accessibilityHint("abre a conversa")
            .accessibilityIdentifier(A11yID.searchResult(thread.id))
            .transition(reduceMotion ? .opacity : .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 6)),
                removal: .opacity
            ))
    }
}
