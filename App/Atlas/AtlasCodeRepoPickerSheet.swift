import SwiftUI
import AtlasCore

// Troca de repositório no grafo — mesmo vocabulário visual do picker da home
// (AtlasTheme.bg, card, gesto pra fechar). Sem scan de violações (rápido).

struct AtlasCodeRepoPickerSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: AtlasCodeWorkspaceModel
    let currentRepo: String
    let onPick: (String) -> Void

    init(client: AtlasClient, currentRepo: String, onPick: @escaping (String) -> Void) {
        let catalog = AtlasCodeWorkspaceModel(client: client)
        catalog.seedFromCache()
        _model = State(initialValue: catalog)
        self.currentRepo = currentRepo
        self.onPick = onPick
    }

    var body: some View {
        NavigationStack {
            Group {
                switch model.phase {
                case .loaded:
                    if let workspace = model.workspace, workspace.repositoryCount > 0 {
                        repoScroll(workspace)
                    } else {
                        ContentUnavailableView(
                            "sem repositórios",
                            systemImage: "folder",
                            description: Text("o workspace não publicou nenhum repo")
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("sem repositórios, o workspace não publicou nenhum repo")
                    }
                case .failed:
                    ContentUnavailableView(
                        "não consegui ler a frota",
                        systemImage: "wifi.slash",
                        description: Text("tente de novo em instantes")
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("não consegui ler a frota, tente de novo em instantes")
                default:
                    VStack(spacing: 12) {
                        BreathingDiamond(size: 10, reduceMotion: reduceMotion)
                        Text("lendo os repositórios do Mac…")
                            .font(AtlasFont.serifItalic(15))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("lendo os repositórios do Mac")
                }
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Repositório")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                Text("Repositório")
                    .font(AtlasFont.serif(18))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)
            }
            .task {
                // Cache hit → phase já .loaded; miss → uma ida à rede.
                if model.phase == .idle { await model.loadStructure() }
            }
            .accessibilityIdentifier(A11yID.codeRepoPicker)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AtlasTheme.bg)
    }

    private func repoScroll(_ workspace: AtlasCodeWorkspaceResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if !workspace.recents.isEmpty {
                    section("recentes", repos: workspace.recents)
                }
                ForEach(workspace.folders) { folder in
                    section(folder.name, repos: folder.repos)
                }
                if !workspace.loose.isEmpty {
                    section("avulsos", repos: workspace.loose)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .padding(.bottom, 28)
        }
    }

    private func section(_ title: String, repos: [AtlasCodeRepoRef]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(AtlasFont.mono(11, .medium))
                .tracking(1.6)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: 0) {
                ForEach(Array(repos.enumerated()), id: \.element.id) { index, repo in
                    repoRow(repo)
                    if index < repos.count - 1 {
                        Divider().overlay(AtlasTheme.separatorSoft)
                    }
                }
            }
            .atlasCard()
        }
    }

    private func repoRow(_ repo: AtlasCodeRepoRef) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onPick(repo.slug)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "folder")
                    .font(.system(size: 15))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(repo.name)
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if repo.slug == currentRepo {
                    Circle()
                        .fill(AtlasTheme.accent)
                        .frame(width: 6, height: 6)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            repo.slug == currentRepo
                ? "\(repo.name), repositório atual"
                : repo.name
        )
        .accessibilityHint(repo.slug == currentRepo ? "já aberto no grafo" : "abre o grafo deste repositório")
        .accessibilityAddTraits(repo.slug == currentRepo ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier(A11yID.codeRepoPickerRow(repo.slug))
    }
}
