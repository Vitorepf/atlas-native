import SwiftUI
import AtlasCore

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

    @ViewBuilder
    private var conversasSection: some View {
        sectionLabel("CONVERSAS", accessibilityID: A11yID.homeConversasSection)
        homeWorkspaceChips
        WorkspaceRow(icon: "bubble.left.and.bubble.right", name: homeConversationLabel,
                     count: homeConversationCount,
                     detail: session.auditModeEnabled ? auditDetail : nil) {
            onNavigate(homeConversationRoute)
        }
        .accessibilityLabel(conversasSpokenLabel(label: homeConversationLabel, count: homeConversationCount))
        .accessibilityHint("abre conversas deste filtro")
        .accessibilityIdentifier(A11yID.homeConversasEntry)
    }

    @ViewBuilder
    private var operacaoSection: some View {
        sectionLabel("OPERAÇÃO", accessibilityID: A11yID.homeOperacaoSection)
        WorkspaceRow(icon: "bolt.horizontal.circle", name: "Autônomos", count: nil) {
            onNavigate(.autonomos)
        }
        .accessibilityLabel("Autônomos, abre frota e digest")
        .accessibilityIdentifier(A11yID.homeAutonomosEntry)
        rowDivider
        WorkspaceRow(
            icon: "chart.line.uptrend.xyaxis",
            name: "Arena",
            count: nil,
            detail: session.arena.regressionException,
            badge: session.arena.regressionException != nil
        ) {
            onNavigate(.arena)
        }
        .accessibilityLabel(arenaSpokenLabel(
            regression: session.arena.regressionException,
            domainUnavailable: session.arena.isDomainUnavailable
        ))
        .accessibilityHint("abre medição de regressão")
        .accessibilityIdentifier(A11yID.arenaHomeEntry)
    }
}
