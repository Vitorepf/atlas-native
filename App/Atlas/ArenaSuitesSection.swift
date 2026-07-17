import SwiftUI
import Charts
import AtlasCore

// MARK: - Arena SUITES section
// Rows/sparkline → ArenaSuitesSection+Rows.swift · Sheets → ArenaSuiteSheet.
// A11y → ArenaSuitesSection+A11y.swift · Sem suites = silêncio total (lei V1).

struct ArenaSuitesSection: View {
    let scoreboard: AtlasArenaScoreboard?
    let reduceMotion: Bool
    let onSuiteTap: (AtlasArenaSuite) -> Void

    private var suites: [AtlasArenaSuite] {
        scoreboard?.suites ?? []
    }

    var body: some View {
        if !suites.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("SUITES")
                        .font(.system(.caption, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Text("\(suites.count)")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                }

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
}
