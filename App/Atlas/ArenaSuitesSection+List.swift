import SwiftUI
import Charts
import AtlasCore

// Lista de suites — peel de ArenaSuitesSection.
// Rows → ArenaSuitesSection+Rows.swift

extension ArenaSuitesSection {
    var suitesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            suitesHeader
            suiteRows
        }
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ArenaSuitesSectionA11y.spokenSection(suites))
        .accessibilityIdentifier(A11yID.arenaSuitesSection)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: suites.map(\.id))
    }
}
