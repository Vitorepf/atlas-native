import AtlasCore
import SwiftUI

// Repo row a11y chrome — peel de AtlasCodeRadarRows.

extension AtlasCodeRepoRow {
    var repoRowA11yChrome: some View {
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
