import SwiftUI
import AtlasCore

// Linhas do picker — peel de AtlasWorkspacePickerSheet.

extension AtlasWorkspacePickerSheet {
    /// Todos os repos reais do Mac, sem duplicata, filtrados pela busca.
    var pickerRepos: [AtlasCodeRepoRef] {
        guard let ws = model.workspace else { return [] }
        var seen = Set<String>()
        let all = (ws.folders.flatMap(\.repos) + ws.loose + ws.recents)
            .filter { seen.insert($0.slug).inserted }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        guard !query.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(query)
            || ($0.folder?.localizedCaseInsensitiveContains(query) ?? false) }
    }

    var pickerRepoList: some View {
        ScrollView {
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
            .padding(.vertical, 12)
        }
    }

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
