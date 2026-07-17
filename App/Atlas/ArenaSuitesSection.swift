import SwiftUI
import Charts
import AtlasCore

// MARK: - Arena SUITES section
// Rows/sparkline → ArenaSuitesSection+Rows.swift · Sheets → ArenaSuiteSheet.

struct ArenaSuitesSection: View {
    let scoreboard: AtlasArenaScoreboard?
    let onSuiteTap: (AtlasArenaSuite) -> Void

    var body: some View {
        if let suites = scoreboard?.suites, !suites.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("SUITES")
                        .font(.system(.caption, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(AtlasTheme.textTertiary)
                    Spacer()
                    Text("\(suites.count)")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityLabel("\(suites.count) suites")
                }

                ForEach(suites) { suite in
                    Button { onSuiteTap(suite) } label: {
                        ArenaSuiteRow(suite: suite)
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(suite.suite), \(suite.arenaSubtitleText)")
                    .accessibilityIdentifier("arena-suite-\(suite.suite)")
                }
            }
            .padding(16)
            .atlasCard()
            .accessibilityIdentifier(A11yID.arenaSuitesSection)
        }
    }
}
