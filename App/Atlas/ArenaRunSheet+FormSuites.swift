import SwiftUI
import AtlasCore

// Suites form — peel de ArenaRunSheet+Form.
// Engine → ArenaRunSheet+FormEngine.swift
// Empty → ArenaRunSheet+FormSuitesEmpty.swift

extension ArenaRunSheet {
    @ViewBuilder
    var suitesFormSection: some View {
        section("SUITES COM ADAPTER") {
            if installedSuites.isEmpty {
                suitesEmptyLabel
            } else {
                ForEach(installedSuites) { suite in
                    toggleRow(
                        title: suite.suite,
                        subtitle: suite.isMeasured ? "\(suite.runsTotal) rodadas" : "não medido",
                        isOn: selectedSuites.contains(suite.suite)
                    ) {
                        if selectedSuites.contains(suite.suite) { selectedSuites.remove(suite.suite) }
                        else { selectedSuites.insert(suite.suite) }
                    }
                    .accessibilityIdentifier("arena-run-suite-\(suite.suite)")
                }
            }
        }
    }
}
