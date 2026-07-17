import AtlasCore
import SwiftUI

// Repo row spoken bind — peel de AtlasCodeRadarRows+A11yChrome.

extension AtlasCodeRepoRow {
    func repoRowSpokenBind<V: View>(_ button: V) -> some View {
        button
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
