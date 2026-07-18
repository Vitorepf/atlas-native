import SwiftUI
import AtlasCore

extension RootHomeSections {
    // Cursor-parity (ordem 2026-07-18): os 3 mais recentes + Adicionar.
    // Sem "Todas as conversas": agregado duplicava livres + workspaces.
    @ViewBuilder
    var workspacesSection: some View {
        sectionLabel("WORKSPACES", accessibilityID: A11yID.homeWorkspacesSection)
        ForEach(session.recentWorkspaces(3)) { ws in
            rowDivider
            workspaceFolderRow(ws)
        }
        rowDivider
        addWorkspaceRow
    }
}
