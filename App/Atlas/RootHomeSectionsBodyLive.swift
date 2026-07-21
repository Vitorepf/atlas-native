import SwiftUI
import AtlasCore

// WAVE-135 RootHomeSections body live peel

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

extension RootHomeSections {
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
}

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

extension RootHomeSections {
    @ViewBuilder
    var phaseBody: some View {
        homeLoadingGate
    }
}

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

