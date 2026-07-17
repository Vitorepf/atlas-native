import SwiftUI
import Charts
import AtlasCore

// Lista de suites — peel de ArenaSuitesSection.

extension ArenaSuitesSection {
    var suitesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            suitesHeader

            ForEach(suites) { suite in
                Button { onSuiteTap(suite) } label: {
                    ArenaSuiteRow(suite: suite)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(ArenaSuitesSectionA11y.spokenSuite(suite))
                .accessibilityHint("abre detalhes da suite")
                .accessibilityIdentifier("arena-suite-\(suite.suite)")
                .transition(reduceMotion ? .identity : .opacity)
            }
        }
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArenaSuitesSectionA11y.spokenSection(suites))
        .accessibilityIdentifier(A11yID.arenaSuitesSection)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: suites.map(\.id))
    }
}
