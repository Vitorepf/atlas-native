import SwiftUI
import AtlasCore

// Seção OPERAÇÃO — peel de RootHomeSections+Loaded.
// Arena → RootHomeSections+ArenaEntry.swift

extension RootHomeSections {
    @ViewBuilder
    var operacaoSection: some View {
        sectionLabel("OPERAÇÃO", accessibilityID: A11yID.homeOperacaoSection)
        WorkspaceRow(
            icon: "bolt.horizontal.circle",
            name: "Autônomos",
            count: nil,
            a11yID: A11yID.homeAutonomosEntry,
            spokenOverride: "Autônomos, abre frota e digest"
        ) {
            onNavigate(.autonomos)
        }
        rowDivider
        arenaEntryRow
    }
}
