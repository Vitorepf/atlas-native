import AtlasCore
import SwiftUI

/// M3 · Código — o workspace do operador como ele realmente é.
/// Seções / linhas → AtlasCodeRadarSections / AtlasCodeRadarRows / FolderRow.
struct AtlasCodeRadarView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    init(client: AtlasClient, onOpenRepo: @escaping (String) -> Void) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.onOpenRepo = onOpenRepo
    }

    private var contentPhaseID: String {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .failed: return "failed"
        case .loaded:
            guard let workspace = model.workspace else { return "loaded-nil" }
            if workspace.repositoryCount == 0 { return "loaded-empty" }
            return "loaded-\(workspace.repositoryCount)"
        }
    }

    private static let shellHint = "pastas, recentes e sem retorno verificados do seu código"

    var body: some View {
        radarContent
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            .navigationTitle("Código")
            .navigationBarTitleDisplayMode(.inline)
            .task { if model.phase == .idle { await model.load() } }
            .refreshable { await model.load() }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .accessibilityIdentifier(A11yID.radarScreen)
            // Contain without fused label: folder/repo rows stay focusable.
            .accessibilityElement(children: .contain)
            .accessibilityHint(Self.shellHint)
    }

    @ViewBuilder
    private var radarContent: some View {
        switch model.phase {
        case .idle, .loading:
            TraceEvidenceLoading(text: "lendo o seu workspace…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier(A11yID.radarLoading)
        case .failed(let message):
            AtlasCodeLoadFailureEmpty(
                headline: "não consegui ler o workspace",
                message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                onRetry: { Task { await model.load() } }
            )
            .accessibilityLabel(spokenFailed(message))
            .accessibilityHint("reconecta ao servidor Atlas")
            .accessibilityIdentifier(A11yID.radarFailure)
        case .loaded:
            if let workspace = model.workspace {
                AtlasCodeRadarLoadedContent(
                    workspace: workspace,
                    model: model,
                    onOpenRepo: onOpenRepo
                )
            } else {
                AtlasEditorialGlyphEmpty(
                    headline: "“Workspace sem repositórios legíveis.”",
                    footnote: "o Mac respondeu, mas nenhuma pasta de produto veio nesta leitura",
                    accessibilityIdentifier: A11yID.radarEmpty,
                    spokenLabel: spokenEmptyWorkspace()
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Spoken (phase-local; shell uses contain-without-fuse)

    private func spokenEmptyWorkspace() -> String {
        "nenhum repositório neste workspace"
    }

    private func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "workspace indisponível" }
        return "workspace indisponível, \(trimmed)"
    }
}
