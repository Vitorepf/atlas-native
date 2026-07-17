import AtlasCore
import SwiftUI

/// M3 · Código — o workspace do operador como ele realmente é.
/// Seções / linhas → AtlasCodeRadarSections.swift; model → AtlasCodeWorkspaceModel.swift.
struct AtlasCodeRadarView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    init(client: AtlasClient, onOpenRepo: @escaping (String) -> Void) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.onOpenRepo = onOpenRepo
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            content
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
        }
        .navigationTitle("Código")
        .navigationBarTitleDisplayMode(.inline)
        .task { if model.phase == .idle { await model.load() } }
        .refreshable { await model.load() }
        .accessibilityIdentifier(A11yID.radarScreen)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(radarShellSpokenLabel)
        .accessibilityHint(Self.shellHint)
    }

    @ViewBuilder
    private var content: some View {
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
                AtlasCodeRadarLoadedContent(workspace: workspace, model: model, onOpenRepo: onOpenRepo)
            } else {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel(spokenEmptyWorkspace())
            }
        }
    }
}
