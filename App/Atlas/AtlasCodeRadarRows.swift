import AtlasCore
import SwiftUI

// Linhas de repositório e pasta do radar — peel de AtlasCodeRadarSections.
// Label → AtlasCodeRadarRows+Label.swift

struct AtlasCodeRepoRow: View {
    let repo: AtlasCodeRepoRef
    let issues: [AtlasCodeIssue]?
    /// A trunk real deste repo: a frase da issue fala o nome da linha.
    var trunk: String? = nil
    /// Nos recentes a pasta situa; dentro da pasta seria redundante.
    let showsFolder: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            repoRowLabel
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AtlasCodeRadarRowsA11y.spokenRepo(
                name: repo.name,
                folder: repo.folder,
                showsFolder: showsFolder,
                issues: issues,
                trunk: trunk,
                lastCommitAt: repo.lastCommitAt
            )
        )
        .accessibilityHint(AtlasCodeRadarRowsA11y.repoHint)
        .accessibilityIdentifier(A11yID.radarRepo(repo.slug))
    }
}
