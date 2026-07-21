import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

struct AtlasWorkspacePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var model: AtlasCodeWorkspaceModel
    @State var query = ""
    let title: String
    let onNoRepo: (() -> Void)?
    let onPick: (_ key: String, _ title: String) -> Void

    init(
        client: AtlasClient,
        title: String = "Adicionar workspace",
        onNoRepo: (() -> Void)? = nil,
        onPick: @escaping (_ key: String, _ title: String) -> Void
    ) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.title = title
        self.onNoRepo = onNoRepo
        self.onPick = onPick
    }

    private var showsNoRepo: Bool { onNoRepo != nil && query.isEmpty }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showsNoRepo { noRepoRow }
                pickerContent
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle(title)
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

extension AtlasWorkspacePickerSheet {
    var pickerRepos: [AtlasCodeRepoRef] {
        guard let ws = model.workspace else { return [] }
        var seen = Set<String>()
        let all = (ws.folders.flatMap(\.repos) + ws.loose + ws.recents)
            .filter { seen.insert($0.slug).inserted }
            .sorted { a, b in
                switch (a.lastCommitAt, b.lastCommitAt) {
                case let (x?, y?): return x > y
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil): return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
                }
            }
        guard !query.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(query)
            || ($0.folder?.localizedCaseInsensitiveContains(query) ?? false) }
    }

    var noRepoRow: some View {
        Button {
            onNoRepo?()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bubble.left")
                    .atlasSans(16)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sem repositório").atlasSans(16, .medium)
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("conversar ou pesquisar, sem projeto").atlasSans(13)
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer()
                Image(systemName: "chevron.right").atlasSans(13, .semibold)
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.horizontal, 14).padding(.vertical, 14)
            .contentShape(Rectangle())
            .atlasCard()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("sem repositório")
        .accessibilityHint("conversa geral com o Atlas, sem projeto")
        .accessibilityIdentifier(A11yID.workspacePickerNoRepo)
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 12)
    }

    var pickerRepoList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("REPOSITÓRIOS")
                    .font(AtlasFont.mono(11, .medium)).tracking(1.6)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, showsNoRepoSpacing ? 18 : 4)
                VStack(spacing: 0) {
                    ForEach(pickerRepos) { repo in
                        pickerRepoRow(repo)
                        if repo.id != pickerRepos.last?.id {
                            Divider().overlay(AtlasTheme.separatorSoft)
                        }
                    }
                }
                .atlasCard()
                .padding(.horizontal, AtlasTheme.Space.screen)
            }
            .padding(.vertical, 12)
        }
    }

    private var showsNoRepoSpacing: Bool { onNoRepo != nil && query.isEmpty }

    private func pickerRepoRow(_ repo: AtlasCodeRepoRef) -> some View {
        Button {
            onPick(repo.slug, repo.name)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "folder")
                    .atlasSans(15)
                    .foregroundStyle(AtlasTheme.textTertiary)
                HStack(spacing: 0) {
                    if let folder = repo.folder {
                        Text("\(folder)/").atlasSans(15).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    Text(repo.name).atlasSans(15, .medium).foregroundStyle(AtlasTheme.textPrimary)
                }
                .lineLimit(1)
                Spacer()
                if let age = AtlasCodeAge.short(from: repo.lastCommitAt) {
                    Text(age).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(repo.folder.map { "\($0), " } ?? "")\(repo.name)")
        .accessibilityHint("abre o workspace deste repositório")
        .accessibilityIdentifier(A11yID.workspacePickerRow(repo.slug))
    }
}
