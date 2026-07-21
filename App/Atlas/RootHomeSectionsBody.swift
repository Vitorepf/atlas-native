import SwiftUI
import AtlasCore

// IDLE-COMPRESS body

// --- RootHomeSections+A11y.swift ---


// --- RootHomeSections+A11yArena.swift ---
extension RootHomeSections {
    func arenaSpokenLabel(regression: String?, domainUnavailable: Bool) -> String {
        if let regression { return "Arena, \(regression)" }
        if domainUnavailable { return "Arena, \(ArenaModel.domainUnavailableCopy)" }
        return "Arena, abre medição de regressão"
    }
}

// --- RootHomeSections+A11yCodeBar.swift ---
extension RootHomeSections {
    static func codeTopBarLabel(hub: AtlasCodeHubModel?) -> String {
        guard let hub else { return "Atlas Código" }
        if let exception = hub.exception {
            return "Atlas Código, \(exception.count) exceções em \(exception.repo)"
        }
        return "Atlas Código, código quieto"
    }
}

// --- RootHomeSections+A11yVisibility.swift ---
extension RootHomeSections {
    /// WORKSPACES some quando não há pastas reais.
    var showsWorkspacesSection: Bool { !session.workspaces.isEmpty }
}

// --- RootHomeSections+A11yWorkspaceLabel.swift ---
extension RootHomeSections {
    func workspaceSpokenLabel(name: String, count: Int?) -> String {
        guard let count else { return name }
        return "\(name), \(count) conversa\(count == 1 ? "" : "s")"
    }
}

// --- RootHomeSections+AddWorkspace.swift ---
extension RootHomeSections {
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
}

// --- RootHomeSections+ArenaEntry.swift ---
extension RootHomeSections {
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
}

// --- RootHomeSections+Conversas.swift ---
extension RootHomeSections {
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
}

// --- RootHomeSections+Conversation+A11yEntry.swift ---
extension RootHomeSections {
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
}

// --- RootHomeSections+Conversation.swift ---


// --- RootHomeSections+ConversationAudit.swift ---
extension RootHomeSections {
    var auditDetail: String {
        let n = homeConversationCount ?? 0
        return "auditoria · livres · \(n) threads"
    }
}

// --- RootHomeSections+ConversationCounts.swift ---
extension RootHomeSections {
    var homeConversationThreadCount: Int { freeThreadCount }
}

// --- RootHomeSections+ConversationFree.swift ---
extension RootHomeSections {
    var freeThreadCount: Int {
        session.threads.filter { $0.workspace == nil }.count
    }
}

// --- RootHomeSections+ConversationOptional.swift ---
extension RootHomeSections {
    var homeConversationCount: Int? {
        let n = homeConversationThreadCount
        return n > 0 ? n : nil
    }
}

// --- RootHomeSections+Failure.swift ---
extension RootHomeSections {
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

// --- RootHomeSections+Layout.swift ---
extension RootHomeSections {
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

// --- RootHomeSections+Loaded.swift ---
extension RootHomeSections {
    @ViewBuilder
    var loadedHome: some View {
        ScrollView {
            loadedHomeStack
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }
}

// --- RootHomeSections+LoadedLiveNow.swift ---
extension RootHomeSections {
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
}

// --- RootHomeSections+LoadedStack.swift ---
extension RootHomeSections {
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

// --- RootHomeSections+Loading.swift ---
extension RootHomeSections {
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
}

// --- RootHomeSections+Operacao.swift ---
extension RootHomeSections {
    @ViewBuilder
    var operacaoSection: some View {
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
        arenaEntryRow
    }
}

// --- RootHomeSections+PhaseBody+LoadingGate.swift ---
extension RootHomeSections {
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
}

// --- RootHomeSections+PhaseBody.swift ---
extension RootHomeSections {
    @ViewBuilder
    var phaseBody: some View {
        homeLoadingGate
    }
}

// --- RootHomeSections+WorkspaceFolderRow.swift ---
extension RootHomeSections {
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
}

// --- RootHomeSections+Workspaces.swift ---
extension RootHomeSections {
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
}

