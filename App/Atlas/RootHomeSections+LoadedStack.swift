import SwiftUI
import AtlasCore

// Stack de seções do home carregado — peel de RootHomeSections+Loaded.

extension RootHomeSections {
    @ViewBuilder
    var loadedHomeStack: some View {
        LazyVStack(spacing: 0) {
            if !TurnPresence.shared.liveSessions.isEmpty || !session.remoteLiveSessions.isEmpty {
                LiveNowSection(
                    localSessions: TurnPresence.shared.liveSessions,
                    remoteSessions: session.remoteLiveSessions,
                    onOpen: onOpenThread
                )
            }
            conversasSection
            rowDivider
            operacaoSection
            if showsWorkspacesSection {
                rowDivider
                workspacesSection
            }
        }
        .padding(.bottom, 96)
    }
}
