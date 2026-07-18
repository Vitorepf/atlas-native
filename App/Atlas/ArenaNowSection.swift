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
    @State var queueExpanded = false

    var runs: [AtlasArenaLiveRun] {
        liveRuns?.runs ?? []
    }

    /// Só o que RODA vira linha — fila é resumo (crítica do operador
    /// 2026-07-18: 17 linhas quase idênticas era lista de máquina).
    var runningRuns: [AtlasArenaLiveRun] {
        runs.filter { if case .running = $0.status { true } else { false } }
    }

    /// Suítes distintas aguardando, na ordem da fila — o par com/sem Atlas
    /// é a unidade de medição, não duas notícias.
    var queuedSuiteNames: [String] {
        var seen = Set<String>()
        return runs.compactMap { run in
            if case .running = run.status { return nil }
            return seen.insert(run.suite).inserted ? ArenaDisplay.suite(run.suite) : nil
        }
    }

    var runningCount: Int { runningRuns.count }

    var body: some View {
        if liveRuns != nil {
            nowSectionBody
        }
    }
}
