import SwiftUI
import AtlasCore

// Arena entry a11y — peel de RootHomeSections+ArenaEntry.

extension RootHomeSections {
    @ViewBuilder
    func arenaEntryA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(arenaSpokenLabel(
                regression: session.arena.regressionException,
                domainUnavailable: session.arena.isDomainUnavailable
            ))
            .accessibilityHint("abre medição de regressão")
            .accessibilityIdentifier(A11yID.arenaHomeEntry)
    }
}
