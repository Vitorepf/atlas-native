import SwiftUI
import AtlasCore

// Conteúdo da home (estados + listas CONVERSAS/OPERAÇÃO/WORKSPACES) —
// peel de RootView. Route e NavigationStack ficam no shell.
// Failure → RootHomeSections+Failure.swift; chips → RootHomeSections+Conversation.swift.

struct RootHomeSections: View {
    @Environment(AtlasSession.self) private var session
    var reduceMotion: Bool
    @Binding var homeWorkspaceFilter: String?
    var onNavigate: (Route) -> Void
    var onOpenThread: (ThreadID, String) -> Void

    var body: some View {
        switch session.phase {
        case .idle where session.threads.isEmpty, .loading where session.threads.isEmpty:
            centered {
                VStack(spacing: 18) {
                    BreathingGlyph(reduceMotion: reduceMotion)
                    Text("abrindo o Atlas…")
                        .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("abrindo o Atlas")
                .accessibilityIdentifier(A11yID.homeLoading)
            }

        case .failed where session.threads.isEmpty:
            failureSection

        default:
            ScrollView {
                LazyVStack(spacing: 0) {
                    if !TurnPresence.shared.liveSessions.isEmpty || !session.remoteLiveSessions.isEmpty {
                        LiveNowSection(
                            localSessions: TurnPresence.shared.liveSessions,
                            remoteSessions: session.remoteLiveSessions,
                            onOpen: onOpenThread
                        )
                    }
                    sectionLabel("CONVERSAS")
                    homeWorkspaceChips
                    WorkspaceRow(icon: "bubble.left.and.bubble.right", name: homeConversationLabel,
                                 count: homeConversationCount,
                                 detail: session.auditModeEnabled ? auditDetail : nil) {
                        onNavigate(homeConversationRoute)
                    }
                    rowDivider
                    sectionLabel("OPERAÇÃO")
                    WorkspaceRow(icon: "bolt.horizontal.circle", name: "Autônomos", count: nil) {
                        onNavigate(.autonomos)
                    }
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
                    .accessibilityIdentifier(A11yID.arenaHomeEntry)
                    rowDivider
                    sectionLabel("WORKSPACES")

                    WorkspaceRow(icon: "tray.full", name: "Todas as conversas", count: session.threads.count) {
                        onNavigate(.workspace(key: nil, title: "Todas"))
                    }
                    ForEach(session.workspaces) { ws in
                        rowDivider
                        WorkspaceRow(icon: "folder", name: ws.name, count: ws.count) {
                            onNavigate(.workspace(key: ws.id, title: ws.name))
                        }
                    }
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .refreshable { await session.loadThreads() }
        }
    }

    var rowDivider: some View {
        Divider().overlay(AtlasTheme.separator).padding(.leading, AtlasTheme.Space.screen + 36)
    }

    func centered<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        VStack { Spacer(); v(); Spacer() }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
