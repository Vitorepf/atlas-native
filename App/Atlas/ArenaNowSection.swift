import SwiftUI
import AtlasCore

/// AGORA — só existe com run vivo (spec §E). Sem runs = silêncio total (lei V1).
/// Indicator → ArenaNowSection+Indicator.swift · Rows → +Rows.swift
/// Body → ArenaNowSection+Body.swift
struct ArenaNowSection: View {
    let liveRuns: AtlasArenaLiveRuns?
    let reduceMotion: Bool

    var runs: [AtlasArenaLiveRun] {
        liveRuns?.runs ?? []
    }

    var body: some View {
        if !runs.isEmpty {
            nowSectionBody
        }
    }
}
