import SwiftUI
import Charts
import AtlasCore

// Suite rows — peel de ArenaSuitesSection+List.

extension ArenaSuitesSection {
    var suiteRows: some View {
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
}
