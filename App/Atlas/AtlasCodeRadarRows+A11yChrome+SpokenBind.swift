import AtlasCore
import SwiftUI

// Repo row spoken bind — peel de AtlasCodeRadarRows+A11yChrome.

extension AtlasCodeRepoRow {
    func repoRowSpokenBind<V: View>(_ button: V) -> some View {
        // children:.ignore cria um nó único (Other) com label/id — remover
        // isso derrubou o app no walk de a11y (SIGSEGV); o TESTE busca por
        // .any, não por .buttons. Não mexer sem bateria 3× verde.
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
