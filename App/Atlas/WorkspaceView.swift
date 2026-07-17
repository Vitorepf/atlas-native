import SwiftUI
import AtlasCore

// Dentro de um workspace (repo): as conversas dele, com filtro de área no topo
// (Tudo / Operacional / Autônomos / Programação). Título em Fraunces serif.
// Vazio ≠ offline: falha de rede usa a mesma voz da home (`AtlasFailureCopy`).
struct WorkspaceView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let workspaceKey: String?
    let title: String
    /// Modo sem projeto: só conversas com workspace nulo (perguntas, pesquisas,
    /// pensamento livre — o uso GPT-no-iPhone). O projeto é opcional, não regra.
    var freeOnly: Bool = false
    @State private var area: AtlasArea = .tudo

    private var threads: [AtlasAiThread] {
        let base = freeOnly
            ? session.threads.filter { $0.workspace == nil }
            : session.threads(inWorkspace: workspaceKey)
        return area == .tudo ? base : base.filter { AtlasArea.of($0) == area }
    }

    /// Sessão sem threads e load falhou → offline/rede, não "vazio editorial".
    private var showsNetworkFailure: Bool {
        guard session.threads.isEmpty else { return false }
        if case .failed = session.phase { return true }
        return false
    }

    private var showsLoadingShell: Bool {
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

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            .accessibilityLabel("voltar")
            Spacer()
            Text(title).font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 4)
    }

    // MARK: - Filtro de área

    private var areaFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AtlasArea.allCases) { a in
                    let active = a == area
                    Button {
                        if reduceMotion {
                            area = a
                        } else {
                            withAnimation(.easeInOut(duration: 0.18)) { area = a }
                        }
                    } label: {
                        Text(a.label)
                            .font(.system(.subheadline, weight: .medium))
                            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textSecondary)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(
                                Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.surface)
                                    .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("área \(a.label)")
                    .accessibilityAddTraits(active ? .isSelected : [])
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
        }
        .padding(.vertical, 10)
        .accessibilityIdentifier(A11yID.workspaceAreaFilter)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: area)
    }

    // MARK: - Lista

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if showsLoadingShell {
                    WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
                } else if showsNetworkFailure {
                    AtlasNetworkFailureEmpty(
                        kind: session.failureKind,
                        hasToken: session.hasToken,
                        host: session.host,
                        accessibilityIdentifier: A11yID.workspaceOffline,
                        onRetry: { Task { await session.loadThreads() } }
                    )
                } else if threads.isEmpty {
                    WorkspaceEditorialEmpty(area: area, freeOnly: freeOnly)
                } else {
                    ForEach(threads) { t in
                        NavigationLink(value: Route.thread(id: ThreadID(t.id), title: t.title)) {
                            ThreadRow(thread: t)
                        }
                        .buttonStyle(.plain)
                        if t.id != threads.last?.id {
                            Divider().overlay(AtlasTheme.separator).padding(.leading, AtlasTheme.Space.screen + 36)
                        }
                    }
                }
            }
            .padding(.bottom, 96)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: area)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: threads.map(\.id))
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }

    // MARK: - Nova conversa

    private var newPill: some View {
        NavigationLink(value: Route.new) {
            HStack(spacing: 10) {
                Image(systemName: "plus").font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30).background(Circle().fill(AtlasTheme.surfaceHi))
                Text("Escreva ao Atlas").font(.system(.callout)).foregroundStyle(AtlasTheme.textTertiary)
                Spacer()
                Image(systemName: "mic.fill").font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Capsule().fill(AtlasTheme.surface).overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("nova conversa")
        .accessibilityIdentifier(A11yID.workspaceNewPill)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}
