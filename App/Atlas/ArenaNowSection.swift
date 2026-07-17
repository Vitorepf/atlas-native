import SwiftUI
import AtlasCore

/// AGORA — só existe com run vivo (spec §E). Sem runs = silêncio total (lei V1).
/// Indicator → ArenaNowSection+Indicator.swift · Rows → +Rows.swift
struct ArenaNowSection: View {
    let liveRuns: AtlasArenaLiveRuns?
    let reduceMotion: Bool

    var runs: [AtlasArenaLiveRun] {
        liveRuns?.runs ?? []
    }

    var body: some View {
        if !runs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("AGORA")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityAddTraits(.isHeader)
                nowRunRows
                Text("Seguir medição na Live Activity: pendente de ActivityKit dedicado para Arena.")
                    .font(.system(.caption))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier(A11yID.arenaNowLiveActivityNote)
            }
            .padding(16)
            .atlasCard()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ArenaNowSectionA11y.spokenSection(runCount: runs.count))
            .accessibilityIdentifier(A11yID.arenaNowSection)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: runs.map(\.id))
        }
    }
}
