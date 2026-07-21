import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: RootHomeSections* peels → RootHomeBody (host + body fused)

// MARK: - Host

struct RootHomeBody: View {
    @Environment(AtlasSession.self) var session
    var reduceMotion: Bool
    var onNavigate: (Route) -> Void
    @State var showingWorkspacePicker = false
    var onOpenThread: (ThreadID, String) -> Void

    var body: some View {
        phaseBody
            // WAVE-047: light ops hydrate — fleet/taskHealth/areas; silence on fail.
            .task {
                await session.autonomos.refreshGlobalOpsForHome()
            }
    }
}

// MARK: - Body / phase gate

extension RootHomeBody {
    @ViewBuilder
    var phaseBody: some View {
        homeLoadingGate
    }

    @ViewBuilder
    var homeLoadingGate: some View {
        switch session.phase {
        case .idle where session.threads.isEmpty, .loading where session.threads.isEmpty:
            loadingHome
        case .failed where session.threads.isEmpty:
            failureSection
        default:
            loadedHome
        }
    }

    var loadingHome: some View {
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

    @ViewBuilder
    var loadedHome: some View {
        ScrollView {
            loadedHomeStack
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }

    @ViewBuilder
    var loadedHomeStack: some View {
        LazyVStack(spacing: 0) {
            liveNowSectionIfNeeded
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

// MARK: - Sections

extension RootHomeBody {
    var showsLiveNowSection: Bool {
        !TurnPresence.shared.liveSessions.isEmpty || !session.remoteLiveSessions.isEmpty
    }

    @ViewBuilder
    var liveNowSectionIfNeeded: some View {
        if showsLiveNowSection {
            LiveNowSection(
                localSessions: TurnPresence.shared.liveSessions,
                remoteSessions: session.remoteLiveSessions,
                onOpen: onOpenThread
            )
        }
    }

    // Modelo mental do operador: conversa é LIVRE ou pertence a um workspace.
    // Uma linha aqui, workspaces na seção deles — zero filtro, zero duplicata.
    @ViewBuilder
    var conversasSection: some View {
        sectionLabel("CONVERSAS", accessibilityID: A11yID.homeConversasSection)
        WorkspaceRow(icon: "bubble.left.and.bubble.right", name: "Conversas livres",
                     count: homeConversationCount,
                     detail: session.auditModeEnabled ? auditDetail : nil,
                     a11yID: A11yID.homeConversasEntry,
                     spokenOverride: conversasEntrySpokenLabel(),
                     spokenHint: "abre as conversas sem workspace") {
            onNavigate(.conversas)
        }
    }

    @ViewBuilder
    var operacaoSection: some View {
        sectionLabel("OPERAÇÃO", accessibilityID: A11yID.homeOperacaoSection)
        // WAVE-047: Autônomos door elevates published attention (silence when quiet).
        WorkspaceRow(
            icon: "bolt.horizontal.circle",
            name: "Autônomos",
            count: nil,
            detail: HomeOpsJudgment.autonomosFace(model: session.autonomos).rowMeta,
            badge: HomeOpsJudgment.autonomosFace(model: session.autonomos).rowMeta != nil
                && HomeOpsJudgment.autonomosFace(model: session.autonomos).productWord != "quiet",
            a11yID: A11yID.homeAutonomosEntry,
            spokenOverride: HomeOpsJudgment.autonomosFace(model: session.autonomos).spokenMeta
        ) {
            onNavigate(.autonomos)
        }
        rowDivider
        arenaEntryRow
    }

    @ViewBuilder
    var arenaEntryRow: some View {
        WorkspaceRow(
            icon: "chart.line.uptrend.xyaxis",
            name: "Arena",
            count: nil,
            // Home NÃO fala de regressão (ordem 2026-07-18, repetida): a linha
            // é limpa; o assunto vive DENTRO da Arena.
            a11yID: A11yID.arenaHomeEntry,
            spokenOverride: arenaSpokenLabel(
                regression: nil,
                domainUnavailable: session.arena.isDomainUnavailable
            ),
            spokenHint: "abre medição de regressão"
        ) {
            onNavigate(.arena)
        }
    }

    /// WORKSPACES some quando não há pastas reais.
    var showsWorkspacesSection: Bool { !session.workspaces.isEmpty }

    // Cursor-parity (ordem 2026-07-18): os 3 mais recentes + Adicionar.
    // Sem "Todas as conversas": agregado duplicava livres + workspaces.
    @ViewBuilder
    var workspacesSection: some View {
        sectionLabel("WORKSPACES", accessibilityID: A11yID.homeWorkspacesSection)
        ForEach(session.recentWorkspaces(3)) { ws in
            rowDivider
            workspaceFolderRow(ws)
        }
        rowDivider
        addWorkspaceRow
    }

    func workspaceFolderRow(_ ws: Workspace) -> some View {
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

    @ViewBuilder
    var addWorkspaceRow: some View {
        WorkspaceRow(icon: "folder.badge.plus", name: "Adicionar workspace",
                     count: nil,
                     a11yID: A11yID.homeAddWorkspace,
                     spokenOverride: "adicionar workspace",
                     spokenHint: "escolhe um repositório do Mac") {
            showingWorkspacePicker = true
        }
        .sheet(isPresented: $showingWorkspacePicker) {
            AtlasWorkspacePickerSheet(client: session.client) { key, title in
                showingWorkspacePicker = false
                onNavigate(.workspace(key: key, title: title))
            }
        }
    }

    @ViewBuilder
    var failureSection: some View {
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
}

// MARK: - Helpers / layout

extension RootHomeBody {
    // Hairline com fade no fim — a linha premium do site, em miniatura.
    var rowDivider: some View {
        LinearGradient(
            colors: [AtlasTheme.separator, AtlasTheme.separator, AtlasTheme.separator.opacity(0)],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(height: 1)
        .padding(.leading, AtlasTheme.Space.screen + 42)
    }

    func centered<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        VStack { Spacer(); v(); Spacer() }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Counts / spoken

extension RootHomeBody {
    var freeThreadCount: Int {
        session.threads.filter { $0.workspace == nil }.count
    }

    var homeConversationThreadCount: Int { freeThreadCount }

    var homeConversationCount: Int? {
        let n = homeConversationThreadCount
        return n > 0 ? n : nil
    }

    var auditDetail: String {
        let n = homeConversationCount ?? 0
        return "auditoria · livres · \(n) threads"
    }

    func conversasEntrySpokenLabel() -> String {
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

    func workspaceSpokenLabel(name: String, count: Int?) -> String {
        guard let count else { return name }
        return "\(name), \(count) conversa\(count == 1 ? "" : "s")"
    }

    func arenaSpokenLabel(regression: String?, domainUnavailable: Bool) -> String {
        // WAVE-047: Home never elevates regression (ordem 2026-07-18).
        _ = regression
        return HomeOpsJudgment.arenaFace(domainUnavailable: domainUnavailable).spoken
    }

    static func codeTopBarLabel(hub: AtlasCodeHubModel?) -> String {
        guard let hub else { return "Atlas Código" }
        if let exception = hub.exception {
            return "Atlas Código, \(exception.count) exceções em \(exception.repo)"
        }
        return "Atlas Código, código quieto"
    }
}

// MARK: - LiveNow section

struct LiveNowSection: View {
    let localSessions: [LiveSessionSnapshot]
    let remoteSessions: [LiveSessionSnapshot]
    let onOpen: (ThreadID, String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// WAVE-064: exclusive attention rank from LiveNowJudgment.
    var sessions: [LiveSessionSnapshot] {
        LiveNowJudgment.rank(local: localSessions, remote: remoteSessions)
    }
    var isHub: Bool { sessions.count >= 2 }
    var remoteCount: Int { sessions.filter(\.isRemote).count }
    var sectionFace: LiveNowSectionFace {
        LiveNowJudgment.sectionFace(count: sessions.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isHub ? 0 : 12) {
            header
            liveNowRows
        }
        .padding(14)
        .atlasCard()
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 18)
        .accessibilityIdentifier(A11yID.liveNowSection)
        .accessibilityLabel(LiveNowJudgment.spokenSection(
            isHub: isHub, count: sessions.count, remoteCount: remoteCount
        ))
        .accessibilityValue(sectionFace.productWord)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: sessions.map(\.id))
    }

    // MARK: - Header

    var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("VIVO AGORA")
                .font(AtlasFont.mono(11))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHidden(true)
            if isHub {
                Text("× \(sessions.count)")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                if remoteCount > 0 {
                    Text("· \(remoteCount) remota\(remoteCount == 1 ? "" : "s")")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, isHub ? 12 : 0)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(LiveNowJudgment.spokenSection(
            isHub: isHub, count: sessions.count, remoteCount: remoteCount
        ))
    }

    // MARK: - Rows

    @ViewBuilder
    var liveNowRows: some View {
        ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
            if isHub, index > 0 {
                Rectangle()
                    .fill(AtlasTheme.separator.opacity(0.55))
                    .frame(height: 1)
                    .padding(.vertical, 10)
            }
            liveNowRowCell(index: index, session: session)
        }
    }

    func liveNowRowCell(index: Int, session: LiveSessionSnapshot) -> some View {
        LiveNowRow(
            session: session,
            hubMode: isHub,
            hubIndex: isHub ? index : nil,
            hubCount: isHub ? sessions.count : nil,
            reduceMotion: reduceMotion,
            remoteBadgeID: session.isRemote ? A11yID.liveNowRemoteBadge(index) : nil
        ) {
            guard let threadId = session.threadId else { return }
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onOpen(threadId, session.title)
        }
        .accessibilityIdentifier(A11yID.liveNowRow(index))
        .transition(reduceMotion ? .opacity : .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 8)),
            removal: .opacity
        ))
    }

}
