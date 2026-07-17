import SwiftUI
import AtlasCore

// Suites + motor — peel de ArenaRunSheet.
// Governance → ArenaRunSheet+FormGovernance.swift

extension ArenaRunSheet {
    @ViewBuilder
    var formSections: some View {
        section("SUITES COM ADAPTER") {
            if installedSuites.isEmpty {
                Text("nenhuma suite com adapter instalado")
                    .font(.system(.subheadline))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityIdentifier(A11yID.arenaRunSuitesEmpty)
                    .accessibilityLabel(spokenEmptySuites())
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

        section("MOTOR") {
            if engines.isEmpty {
                Text("nenhum motor publicado")
                    .font(.system(.subheadline))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityIdentifier(A11yID.arenaRunEnginesEmpty)
                    .accessibilityLabel(spokenEmptyEngines())
            } else {
                ForEach(engines, id: \.self) { engine in
                    toggleRow(title: engine, subtitle: nil, isOn: selectedEngine == engine) {
                        selectedEngine = engine
                    }
                    .accessibilityIdentifier("arena-run-engine-\(engine)")
                }
            }
        }

        formGovernanceSections
    }
}
