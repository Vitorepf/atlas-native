import SwiftUI
import AtlasCore

// Seção OPERAÇÃO — peel de RootHomeSections+Loaded.
// Arena → RootHomeSections+ArenaEntry.swift

extension RootHomeSections {
    @ViewBuilder
    var operacaoSection: some View {
        sectionLabel("OPERAÇÃO", accessibilityID: A11yID.homeOperacaoSection)
        WorkspaceRow(icon: "bolt.horizontal.circle", name: "Autônomos", count: nil) {
            onNavigate(.autonomos)
        }
        .accessibilityLabel("Autônomos, abre frota e digest")
        .accessibilityIdentifier(A11yID.homeAutonomosEntry)
        rowDivider
        arenaEntryRow
    }
}
