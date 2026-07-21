import Foundation
import AtlasCore

// MARK: - Judgment

/// Exclusive Arena live-run status chrome (WAVE-107).
/// One law for Execution row · Detail kicker · Icon glyph · pack word.
/// Never invents progress % beyond published casesDone/casesTotal.
enum ArenaRunStatusJudgment {

    // MARK: Label / tone / glyph

    /// Product kicker for a single run status (Detail + row dialect).
    static func label(for status: AtlasArenaRunStatus) -> String {
        switch status {
        case .running: return "Ao vivo"
        case .stopping: return "Parando"
        case .queued: return "Na fila"
        case .completed: return "Concluída"
        case .failed: return "Falhou"
        case .stopped: return "Parada"
        case .unknown: return "Estado"
        }
    }

    static func tone(for status: AtlasArenaRunStatus) -> ArenaPremiumTone {
        switch status {
        case .queued, .running, .stopping: return .active
        case .completed: return .positive
        case .failed: return .negative
        case .stopped, .unknown: return .neutral
        }
    }

    /// Compact list glyph — never Atlas ✦ on runs.
    static func rowGlyph(for status: AtlasArenaRunStatus) -> String {
        switch status {
        case .running, .stopping: return "▸"
        case .completed: return "✓"
        case .failed: return "※"
        case .queued: return "◷"
        case .stopped, .unknown: return "·"
        }
    }

    /// SF Symbol for icon chrome (Icon.run).
    static func sfSymbol(for status: AtlasArenaRunStatus) -> String {
        switch status {
        case .queued: return "clock"
        case .running: return "play.circle"
        case .stopping: return "hourglass"
        case .stopped: return "stop.circle"
        case .completed: return "checkmark.circle"
        case .failed: return "exclamationmark.triangle"
        case .unknown: return "questionmark.circle"
        }
    }

    static func productWord(for status: AtlasArenaRunStatus) -> String {
        switch status {
        case .running: return "running"
        case .stopping: return "stopping"
        case .queued: return "queued"
        case .completed: return "completed"
        case .failed: return "failed"
        case .stopped: return "stopped"
        case .unknown: return "unknown"
        }
    }

    static func spoken(for status: AtlasArenaRunStatus) -> String {
        label(for: status)
    }

    // MARK: Row chrome

    static func rowDetail(_ run: AtlasArenaLiveRun) -> String {
        if let done = run.casesDone, let total = run.casesTotal, total > 0 {
            return "\(done)/\(total) casos"
        }
        return run.arm?.labelPT ?? run.status.displayPT
    }

    static func rowTrailing(_ run: AtlasArenaLiveRun) -> String {
        let arm = run.arm?.labelPT
        let state: String
        switch run.status {
        case .running: state = "ao vivo"
        case .stopping: state = "parando"
        case .queued: state = "na fila"
        case .completed: state = "concluída"
        case .failed: state = "falhou"
        case .stopped: state = "parada"
        case .unknown: state = run.status.displayPT
        }
        return [state, arm].compactMap(\.self).joined(separator: " · ")
    }

    /// Detail cases summary (honest published fractions only).
    static func casesSummaryLine(
        status: AtlasArenaRunStatus,
        done: Int,
        total: Int
    ) -> String {
        let remaining = max(0, total - done)
        switch status {
        case .running, .stopping:
            return "\(done) confirmados · 1 em andamento · \(max(0, remaining - 1)) a seguir"
        case .queued:
            return "\(total) na fila · ainda não iniciado"
        case .completed:
            return "\(done) de \(total) concluídos"
        case .failed:
            return "\(done) de \(total) antes da falha"
        case .stopped:
            return "\(done) de \(total) quando parou"
        case .unknown:
            return "\(done) de \(total)"
        }
    }

    // MARK: Pack

    static func packFacts(for status: AtlasArenaRunStatus) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("arena_run_status: \(productWord(for: status))")
        facts.append("arena_run_label: \(label(for: status))")
        if case .unknown = status {
            absences.append("status de corrida desconhecido — silêncio neutro")
        }
        return (facts, absences)
    }
}
