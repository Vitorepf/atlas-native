import SwiftUI
import AtlasCore

/// AGORA — sempre visível quando o feed live carregou (goal do operador
/// 2026-07-17: contagem + quais motores rodando, mesmo quando zero).
/// Feed ausente (fetch falhou) = silêncio; zero runs = estado quieto dito.
/// Indicator → ArenaNowSection+Indicator.swift · Rows → +Rows.swift
/// Body → ArenaNowSection+Body.swift
struct ArenaNowSection: View {
    let liveRuns: AtlasArenaLiveRuns?
    let reduceMotion: Bool

    var runs: [AtlasArenaLiveRun] {
        liveRuns?.runs ?? []
    }

    var runningCount: Int {
        runs.filter { if case .running = $0.status { true } else { false } }.count
    }

    var queuedCount: Int {
        runs.count - runningCount
    }

    var body: some View {
        if liveRuns != nil {
            nowSectionBody
        }
    }
}
