import SwiftUI
import AtlasCore

// Loaded home scroll — peel de RootHomeSections.
// Conversas → +Conversas · Operação → +Operacao

extension RootHomeSections {
    @ViewBuilder
    var loadedHome: some View {
        ScrollView {
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
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }
}
