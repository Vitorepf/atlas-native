import SwiftUI
import AtlasCore

// Suites + motor — peel de ArenaRunSheet.
// Suites/Motor → ArenaRunSheet+FormSuites.swift · Governance → +FormGovernance.swift

extension ArenaRunSheet {
    @ViewBuilder
    var formSections: some View {
        suitesFormSection
        engineFormSection
        formGovernanceSections
    }
}
