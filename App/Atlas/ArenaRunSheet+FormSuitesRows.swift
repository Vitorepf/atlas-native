import SwiftUI
import AtlasCore

// Suites toggle rows — peel de ArenaRunSheet+FormSuites.

extension ArenaRunSheet {
    @ViewBuilder
    var suitesToggleRows: some View {
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
