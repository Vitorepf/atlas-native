import SwiftUI
import AtlasCore

// Suites form — peel de ArenaRunSheet+Form.
// Engine → ArenaRunSheet+FormEngine.swift
// Empty → ArenaRunSheet+FormSuitesEmpty.swift
// Rows → ArenaRunSheet+FormSuitesRows.swift

extension ArenaRunSheet {
    @ViewBuilder
    var suitesFormSection: some View {
        section("SUITES COM ADAPTER") {
            if installedSuites.isEmpty {
                suitesEmptyLabel
            } else {
                suitesToggleRows
            }
        }
    }
}
