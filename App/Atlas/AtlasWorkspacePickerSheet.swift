import SwiftUI
import AtlasCore

// Picker de workspace — sheet da home (referência Cursor, ordem 2026-07-18):
// busca + TODOS os repositórios reais do Mac (via AtlasCodeWorkspaceModel —
// a mesma fonte do radar; a casca não faz rede). Escolher abre o workspace.
// Rows → AtlasWorkspacePickerSheet+Rows.swift

struct AtlasWorkspacePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var model: AtlasCodeWorkspaceModel
    @State var query = ""
    let onPick: (_ key: String, _ title: String) -> Void

    init(client: AtlasClient, onPick: @escaping (_ key: String, _ title: String) -> Void) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.onPick = onPick
    }

    var body: some View {
        NavigationStack {
            pickerContent
                .background(AtlasTheme.bg.ignoresSafeArea())
                .navigationTitle("Adicionar workspace")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $query, prompt: "Buscar repositórios")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Fechar") { dismiss() }.atlasSans(15, .medium)
                            .tint(AtlasTheme.textSecondary)
                    }
                }
                .task { if case .idle = model.phase { await model.load() } }
                .accessibilityIdentifier(A11yID.workspacePickerSheet)
        }
    }

    @ViewBuilder
    private var pickerContent: some View {
        switch model.phase {
        case .idle, .loading:
            VStack(spacing: 12) {
                BreathingDiamond(size: 10, reduceMotion: false)
                Text("lendo os repositórios do Mac…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed:
            VStack(spacing: 10) {
                Text("O Mac não respondeu.")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Button("Tentar de novo") { Task { await model.load() } }
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        default:
            pickerRepoList
        }
    }
}
