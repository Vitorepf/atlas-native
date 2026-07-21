import SwiftUI
import AtlasCore

// WAVE-011 radar surface extensions

extension AtlasCodeRepoRow {
    var repoRowButton: some View {
        Button(action: onTap) {
            repoRowLabel
        }
        .buttonStyle(.plain)
    }
}

extension AtlasCodeRepoRow {
    func repoRowSpokenBind<V: View>(_ button: V) -> some View {
        // children:.ignore cria um nó único (Other) com label/id — remover
        // isso derrubou o app no walk de a11y (SIGSEGV); o TESTE busca por
        // .any, não por .buttons. Não mexer sem bateria 3× verde.
        button
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                AtlasCodeRadarRowsA11y.spokenRepo(
                    name: repo.name,
                    folder: repo.folder,
                    showsFolder: showsFolder,
                    issues: issues,
                    trunk: trunk,
                    lastCommitAt: repo.lastCommitAt,
                    isMute: isMute
                )
            )
            .accessibilityHint(AtlasCodeRadarRowsA11y.repoHint)
            .accessibilityIdentifier(A11yID.radarRepo(repo.slug))
    }
}

extension AtlasCodeRepoRow {
    var repoRowA11yChrome: some View {
        repoRowSpokenBind(repoRowButton)
    }
}

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoCommitAge(lastCommitAt: Int?) -> String? {
        guard let age = AtlasCodeAge.short(from: lastCommitAt) else { return nil }
        return "último commit \(age)"
    }
}

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoFolder(folder: String?, showsFolder: Bool) -> [String] {
        guard showsFolder, let folder, !folder.isEmpty else { return [] }
        return ["pasta \(folder)"]
    }
}

extension AtlasCodeRadarRowsA11y {
    static func spokenRepo(
        name: String,
        folder: String?,
        showsFolder: Bool,
        issues: [AtlasCodeIssue]?,
        trunk: String?,
        lastCommitAt: Int?,
        isMute: Bool = false
    ) -> String {
        var parts = [name]
        parts.append(contentsOf: spokenRepoFolder(folder: folder, showsFolder: showsFolder))
        if isMute {
            parts.append(AtlasCodeRadarJudgment.muteSpoken)
        } else {
            parts.append(contentsOf: spokenRepoIssues(issues: issues, trunk: trunk))
        }
        if let age = spokenRepoCommitAge(lastCommitAt: lastCommitAt) {
            parts.append(age)
        }
        return parts.joined(separator: ", ")
    }
}

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoIssueFirst(
        issues: [AtlasCodeIssue],
        trunk: String?
    ) -> [String] {
        guard let first = issues.first else { return [] }
        var parts = [first.headline(trunk: trunk)]
        if first.isSevere { parts.append("alta severidade") }
        return parts
    }
}

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoIssueMore(issues: [AtlasCodeIssue]) -> [String] {
        guard issues.count > 1 else { return [] }
        let more = issues.count - 1
        return ["mais \(more) sem retorno\(more == 1 ? "" : "s")"]
    }
}

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoIssues(
        issues: [AtlasCodeIssue]?,
        trunk: String?
    ) -> [String] {
        guard let issues, !issues.isEmpty else { return [] }
        return spokenRepoIssueFirst(issues: issues, trunk: trunk)
            + spokenRepoIssueMore(issues: issues)
    }
}

extension AtlasCodeRadarStatusCapsule {
    func spokenStatusQuiet(model: AtlasCodeWorkspaceModel) -> String? {
        switch model.scanState {
        case .clean:
            return "código quieto, nada pede você"
        case .unknown:
            return model.headline
        default:
            return nil
        }
    }
}

extension AtlasCodeRadarStatusCapsule {
    /// Frota quieta = caption mínima; alarme só com violação verificada no scan.
    func spokenStatus(model: AtlasCodeWorkspaceModel) -> String {
        spokenStatusQuiet(model: model) ?? "atenção, \(model.headline)"
    }
}

extension AtlasCodeRadarView {
    var contentPhaseID: String {
        contentPhaseBusyID ?? contentPhaseLoadedID
    }

    var contentPhaseBusyID: String? {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .failed: return "failed"
        default: return nil
        }
    }

    var contentPhaseLoadedID: String {
        guard let workspace = model.workspace else { return "loaded-nil" }
        if workspace.repositoryCount == 0 { return "loaded-empty" }
        return "loaded-\(workspace.repositoryCount)"
    }

    var radarShellSpokenLabel: String {
        var parts = ["Código, workspace do operador"]
        if let busy = radarShellBusyParts() {
            parts.append(contentsOf: busy)
        } else {
            parts.append(contentsOf: radarShellLoadedParts())
        }
        return parts.joined(separator: ", ")
    }

    func radarShellBusyParts() -> [String]? {
        switch model.phase {
        case .idle, .loading:
            return [spokenLoading()]
        case .failed(let message):
            return [spokenFailed(message)]
        default:
            return nil
        }
    }

    func radarShellLoadedParts() -> [String] {
        if let workspace = model.workspace, workspace.repositoryCount > 0 {
            let n = workspace.repositoryCount
            return ["\(n) repositório\(n == 1 ? "" : "s")"]
        }
        return [spokenEmptyWorkspace()]
    }

    func spokenEmptyWorkspace() -> String { "nenhum repositório neste workspace" }

    static let shellHint = "pastas, recentes e sem retorno verificados do seu código"

    func spokenLoading() -> String { "lendo o workspace" }

    func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "workspace indisponível" }
        return "workspace indisponível, \(trimmed)"
    }
}

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarContentBusy: some View {
        switch model.phase {
        case .idle, .loading:
            radarLoadingContent
        case .failed(let message):
            radarFailed(message)
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeRadarView {
    var radarLoadingContent: some View {
        TraceEvidenceLoading(text: "lendo o seu workspace…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier(A11yID.radarLoading)
    }
}

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarContent: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            radarContentBusy
        case .loaded:
            radarLoadedOrEmpty
        }
    }
}

extension AtlasCodeRadarView {
    @ViewBuilder
    var radarLoadedOrEmpty: some View {
        if let workspace = model.workspace {
            AtlasCodeRadarLoadedContent(workspace: workspace, model: model, onOpenRepo: onOpenRepo)
        } else {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(spokenEmptyWorkspace())
        }
    }
}

extension AtlasCodeRadarView {
    @ViewBuilder
    func radarFailed(_ message: String) -> some View {
        AtlasCodeLoadFailureEmpty(
            headline: "não consegui ler o workspace",
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            onRetry: { Task { await model.load() } }
        )
        .accessibilityLabel(spokenFailed(message))
        .accessibilityHint("reconecta ao servidor Atlas")
        .accessibilityIdentifier(A11yID.radarFailure)
    }
}

extension AtlasCodeRadarView {
    var radarContentShell: some View {
        // Fundo como .background: a barra nativa precisa enxergar o scroll
        // para ligar o scroll-edge material (ZStack escondia).
        radarNavShell(
            radarContent
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
                .padding(.bottom, 88)
        )
        .background(AtlasTheme.bg.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            askPillDock
        }
        .sheet(isPresented: $showingAsk) {
            askConversationSheet
        }
    }
}

extension AtlasCodeRadarView {
    @ViewBuilder
    func radarNavShell<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Código")
            .navigationBarTitleDisplayMode(.inline)
            .task { if model.phase == .idle { await model.load() } }
            .refreshable { await model.load() }
            .accessibilityIdentifier(A11yID.radarScreen)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(radarShellSpokenLabel)
            .accessibilityHint(Self.shellHint)
    }
}

struct AtlasCodeRadarView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void
    /// Pílula = porta de intenção no Radar (WAVE-001 grafo soberano / julgamento).
    @State var showingAsk = false
    @State var askThreadId: ThreadID?
    @State var askDraft = ""

    var body: some View {
        radarContentShell
    }

    init(client: AtlasClient, onOpenRepo: @escaping (String) -> Void) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.onOpenRepo = onOpenRepo
    }

}

