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
        }
        .navigationTitle("Código")
        .navigationBarTitleDisplayMode(.inline)
        .task { if model.phase == .idle { await model.load() } }
        .refreshable { await model.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle, .loading:
            TraceEvidenceLoading(text: "lendo o seu workspace…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 22))
                    .foregroundStyle(AtlasCodePalette.alert)
                Text("não consegui ler o workspace")
                    .font(AtlasFont.serif(19, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(message)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                Button("Tentar de novo") { Task { await model.load() } }
                    .buttonStyle(.borderedProminent)
                    .tint(AtlasTheme.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            if let workspace = model.workspace {
                AtlasCodeRadarLoadedContent(workspace: workspace, model: model, onOpenRepo: onOpenRepo)
            } else {
                Text("workspace vazio")
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
