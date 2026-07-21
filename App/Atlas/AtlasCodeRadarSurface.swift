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
    /// WAVE-067: exclusive radar screen face from published phase + repo count.
    var radarScreenFace: AtlasCodeRadarScreenFace {
        let fail: String? = {
            if case .failed(let message) = model.phase { return message }
            return nil
        }()
        return AtlasCodeRadarScreenJudgment.face(
            phase: model.phase,
            repositoryCount: model.workspace?.repositoryCount,
            failMessage: fail
        )
    }

    var contentPhaseID: String {
        // idle maps to loading phaseID (honesty: not a distinct product face).
        if case .idle = model.phase { return "idle" }
        return radarScreenFace.phaseID
    }

    var radarShellSpokenLabel: String {
        AtlasCodeRadarScreenJudgment.spokenShell(face: radarScreenFace)
    }

    static var shellHint: String { AtlasCodeRadarScreenJudgment.shellHint }

    func spokenEmptyWorkspace() -> String {
        AtlasCodeRadarScreenFace.empty.spokenFace
    }

    func spokenLoading() -> String {
        AtlasCodeRadarScreenFace.loading.spokenFace
    }

    func spokenFailed(_ message: String) -> String {
        AtlasCodeRadarScreenFace.failed(
            message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : message.trimmingCharacters(in: .whitespacesAndNewlines)
        ).spokenFace
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
            .accessibilityValue(radarScreenFace.productWord)
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

