import SwiftUI
import AtlasCore

extension RootHomeSections {
    // Sem "Todas as conversas": agregado duplicava livres + workspaces
    // (a busca cobre o corte transversal). Só as pastas reais.
    @ViewBuilder
    var workspacesSection: some View {
        sectionLabel("WORKSPACES", accessibilityID: A11yID.homeWorkspacesSection)
        workspaceFolderRows
    }
}
