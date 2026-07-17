import SwiftUI
import Charts
import AtlasCore

// MARK: - Arena SUITES section
// Rows/sparkline → ArenaSuitesSection+Rows.swift · Sheets → ArenaSuiteSheet.
// A11y → ArenaSuitesSection+A11y.swift · Header → +Header.swift
// List → ArenaSuitesSection+List.swift
// Sem suites = silêncio total (lei V1).

struct ArenaSuitesSection: View {
    let scoreboard: AtlasArenaScoreboard?
    let reduceMotion: Bool
    let onSuiteTap: (AtlasArenaSuite) -> Void

    var suites: [AtlasArenaSuite] {
        scoreboard?.suites ?? []
    }

    var body: some View {
        if !suites.isEmpty {
            suitesList
        }
    }
}
