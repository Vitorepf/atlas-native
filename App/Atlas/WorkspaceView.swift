import SwiftUI
import AtlasCore

// Dentro de um workspace (repo): as conversas dele, com filtro de área no topo
// (Tudo / Operacional / Autônomos / Programação). Título em Fraunces serif.
// Vazio ≠ offline: falha de rede usa a mesma voz da home (`AtlasFailureCopy`).
// Chrome em WorkspaceView+Chrome.swift; empty states em WorkspaceEmptyStates.swift.
struct WorkspaceView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let workspaceKey: String?
    let title: String
    /// Modo sem projeto: só conversas com workspace nulo (perguntas, pesquisas,
    /// pensamento livre — o uso GPT-no-iPhone). O projeto é opcional, não regra.
    var freeOnly: Bool = false
    @State var area: AtlasArea = .tudo

    var threads: [AtlasAiThread] {
        let base = freeOnly
            ? session.threads.filter { $0.workspace == nil }
            : session.threads(inWorkspace: workspaceKey)
        return area == .tudo ? base : base.filter { AtlasArea.of($0) == area }
    }

    /// Sessão sem threads e load falhou → offline/rede, não "vazio editorial".
    var showsNetworkFailure: Bool {
        guard session.threads.isEmpty else { return false }
        if case .failed = session.phase { return true }
        return false
    }

    var showsLoadingShell: Bool {
        guard session.threads.isEmpty else { return false }
        switch session.phase {
        case .idle, .loading: return true
        default: return false
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                if !showsNetworkFailure && !showsLoadingShell {
                    areaFilter
                }
                listView
            }
            if !showsNetworkFailure && !showsLoadingShell {
                newPill
            }
        }
        .navigationBarHidden(true)
        .accessibilityIdentifier(A11yID.workspaceScreen)
    }

    var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if showsLoadingShell {
                    WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
                        .accessibilityIdentifier(A11yID.workspaceLoading)
                } else if showsNetworkFailure {
                    AtlasNetworkFailureEmpty(
                        kind: session.failureKind,
                        hasToken: session.hasToken,
                        host: session.host,
                        retryHint: "reconecta e recarrega conversas deste workspace",
                        retryAccessibilityIdentifier: A11yID.workspaceRetry,
                        accessibilityIdentifier: A11yID.workspaceOffline,
                        onRetry: { Task { await session.loadThreads() } }
                    )
                } else if threads.isEmpty {
                    WorkspaceEditorialEmpty(area: area, freeOnly: freeOnly, screenTitle: title)
                } else {
                    WorkspaceThreadsSection(
                        threads: threads,
                        area: area,
                        screenTitle: title,
                        reduceMotion: reduceMotion
                    )
                }
            }
            .padding(.bottom, 96)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: threads.map(\.id))
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }
}
