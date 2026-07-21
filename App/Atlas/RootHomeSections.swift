import SwiftUI
import AtlasCore

/// Conteúdo da home (estados + CONVERSAS / OPERAÇÃO / WORKSPACES / VIVO AGORA).
/// Route e NavigationStack ficam no shell RootView.
struct RootHomeSections: View {
    @Environment(AtlasSession.self) var session
    var reduceMotion: Bool
    var onNavigate: (Route) -> Void
    @State private var showingWorkspacePicker = false
    var onOpenThread: (ThreadID, String) -> Void

    /// WORKSPACES some quando não há pastas reais.
    private var showsWorkspacesSection: Bool { !session.workspaces.isEmpty }

    private var freeThreadCount: Int {
        session.threads.filter { $0.workspace == nil }.count
    }

    private var homeConversationThreadCount: Int { freeThreadCount }

    private var homeConversationCount: Int? {
        let n = homeConversationThreadCount
        return n > 0 ? n : nil
    }

    private var auditDetail: String {
        let n = homeConversationCount ?? 0
        return "auditoria · livres · \(n) threads"
    }

    private var showsLiveNowSection: Bool {
        !TurnPresence.shared.liveSessions.isEmpty || !session.remoteLiveSessions.isEmpty
    }

    var body: some View {
        switch session.phase {
        case .idle where session.threads.isEmpty, .loading where session.threads.isEmpty:
            loadingHome
        case .failed where session.threads.isEmpty:
            failureSection
        default:
            loadedHome
        }
    }

    // MARK: - Loading / failure

    private var loadingHome: some View {
        centered {
            WorkspaceLoadingEmpty(
                reduceMotion: reduceMotion,
                text: "abrindo o Atlas…",
                spoken: "abrindo o Atlas",
                topPadding: 0
            )
            .accessibilityIdentifier(A11yID.homeLoading)
        }
    }

    private var failureSection: some View {
        centered {
            AtlasNetworkFailureEmpty(
                kind: session.failureKind,
                hasToken: session.hasToken,
                host: session.host,
                topPadding: 0,
                retryHint: "reconecta ao servidor Atlas",
                retryAccessibilityIdentifier: A11yID.homeRetry,
                accessibilityIdentifier: A11yID.homeOffline,
                onRetry: { Task { await session.loadThreads() } }
            )
        }
    }

    // MARK: - Loaded

    private var loadedHome: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if showsLiveNowSection {
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

    // MARK: - CONVERSAS

    @ViewBuilder
    private var conversasSection: some View {
        sectionLabel("CONVERSAS", accessibilityID: A11yID.homeConversasSection)
        WorkspaceRow(
            icon: "bubble.left.and.bubble.right",
            name: "Conversas livres",
            count: homeConversationCount,
            detail: session.auditModeEnabled ? auditDetail : nil,
            a11yID: A11yID.homeConversasEntry,
            spokenOverride: conversasEntrySpokenLabel(),
            spokenHint: "abre as conversas sem workspace"
        ) {
            onNavigate(.conversas)
        }
    }

    private func conversasEntrySpokenLabel() -> String {
        var parts = ["Conversas livres"]
        let n = homeConversationThreadCount
        if n == 0 {
            parts.append("nenhuma conversa")
        } else {
            parts.append("\(n) conversa\(n == 1 ? "" : "s")")
        }
        if session.auditModeEnabled {
            parts.append(auditDetail)
        }
        return parts.joined(separator: ", ")
    }

    // MARK: - OPERAÇÃO

    @ViewBuilder
    private var operacaoSection: some View {
        sectionLabel("OPERAÇÃO", accessibilityID: A11yID.homeOperacaoSection)
        WorkspaceRow(
            icon: "bolt.horizontal.circle",
            name: "Autônomos",
            count: nil,
            a11yID: A11yID.homeAutonomosEntry,
            spokenOverride: "Autônomos, abre catálogo de escopos soberanos"
        ) {
            onNavigate(.autonomos)
        }
        rowDivider
        WorkspaceRow(
            icon: "chart.line.uptrend.xyaxis",
            name: "Arena",
            count: nil,
            a11yID: A11yID.arenaHomeEntry,
            spokenOverride: arenaSpokenLabel(
                domainUnavailable: session.arena.isDomainUnavailable
            ),
            spokenHint: "abre medição de regressão"
        ) {
            onNavigate(.arena)
        }
    }

    private func arenaSpokenLabel(domainUnavailable: Bool) -> String {
        if domainUnavailable { return "Arena, \(ArenaModel.domainUnavailableCopy)" }
        return "Arena, abre medição de regressão"
    }

    // MARK: - WORKSPACES

    @ViewBuilder
    private var workspacesSection: some View {
        sectionLabel("WORKSPACES", accessibilityID: A11yID.homeWorkspacesSection)
        ForEach(session.recentWorkspaces(3)) { ws in
            rowDivider
            WorkspaceRow(
                icon: "folder",
                name: ws.name,
                count: ws.count > 0 ? ws.count : nil,
                a11yID: A11yID.homeWorkspace(ws.id),
                spokenOverride: workspaceSpokenLabel(
                    name: ws.name,
                    count: ws.count > 0 ? ws.count : nil
                ),
                spokenHint: "abre conversas deste workspace"
            ) {
                onNavigate(.workspace(key: ws.id, title: ws.name))
            }
        }
        rowDivider
        WorkspaceRow(
            icon: "folder.badge.plus",
            name: "Adicionar workspace",
            count: nil,
            a11yID: A11yID.homeAddWorkspace,
            spokenOverride: "adicionar workspace",
            spokenHint: "escolhe um repositório do Mac"
        ) {
            showingWorkspacePicker = true
        }
        .sheet(isPresented: $showingWorkspacePicker) {
            AtlasWorkspacePickerSheet(client: session.client) { key, title in
                showingWorkspacePicker = false
                onNavigate(.workspace(key: key, title: title))
            }
        }
    }

    private func workspaceSpokenLabel(name: String, count: Int?) -> String {
        guard let count else { return name }
        return "\(name), \(count) conversa\(count == 1 ? "" : "s")"
    }

    /// Spoken da top bar Código (RootView chrome).
    static func codeTopBarLabel(hub: AtlasCodeHubModel?) -> String {
        guard let hub else { return "Atlas Código" }
        if let exception = hub.exception {
            return "Atlas Código, \(exception.count) exceções em \(exception.repo)"
        }
        return "Atlas Código, código quieto"
    }

    // MARK: - Layout

    private var rowDivider: some View {
        LinearGradient(
            colors: [AtlasTheme.separator, AtlasTheme.separator, AtlasTheme.separator.opacity(0)],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(height: 1)
        .padding(.leading, AtlasTheme.Space.screen + 42)
    }

    private func centered<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        VStack { Spacer(); v(); Spacer() }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
