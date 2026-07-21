import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive Arena live-control face (WAVE-050).
enum ArenaLiveControlFace: Equatable {
    case empty
    case queued
    case running
    case stopping
    case attention(Int)
    case quietDone

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .queued: return "queued"
        case .running: return "running"
        case .stopping: return "stopping"
        case .attention: return "attention"
        case .quietDone: return "quiet_done"
        }
    }

    var kicker: String {
        switch self {
        case .empty: return "Medição"
        case .queued: return "Na fila"
        case .running: return "Ao vivo"
        case .stopping: return "Parando"
        case .attention: return "Atenção"
        case .quietDone: return "Encerrada"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem corridas publicadas"
        case .queued:
            return "medição na fila"
        case .running:
            return "medição ao vivo"
        case .stopping:
            return "medição parando"
        case .attention(let n):
            return n == 1 ? "1 corrida falhou" : "\(n) corridas falharam"
        case .quietDone:
            return "medição encerrada sem falhas publicadas"
        }
    }
}

// MARK: - Judgment

/// Pure Arena live control — rank · face · canStop · pack.
enum ArenaLiveControlJudgment {

    /// Lower = higher attention / list priority.
    static func statusRank(_ status: AtlasArenaRunStatus) -> Int {
        switch status {
        case .running: return 0
        case .stopping: return 1
        case .failed: return 2
        case .completed: return 3
        case .stopped: return 4
        case .queued: return 5
        case .unknown: return 6
        }
    }

    static func rank(_ runs: [AtlasArenaLiveRun]) -> [AtlasArenaLiveRun] {
        runs.enumerated().sorted { lhs, rhs in
            let lr = statusRank(lhs.element.status)
            let rr = statusRank(rhs.element.status)
            if lr != rr { return lr < rr }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func face(
        runs: [AtlasArenaLiveRun],
        primary: AtlasArenaLiveRun?
    ) -> ArenaLiveControlFace {
        if runs.isEmpty { return .empty }
        if runs.contains(where: { $0.status == .stopping })
            || primary?.status == .stopping {
            return .stopping
        }
        if runs.contains(where: { $0.status == .running })
            || primary?.status == .running {
            return .running
        }
        let failed = runs.filter { $0.status == .failed }.count
        if failed > 0 { return .attention(failed) }
        if runs.contains(where: { $0.status == .queued }) {
            return .queued
        }
        return .quietDone
    }

    static func canStop(primary: AtlasArenaLiveRun?) -> Bool {
        guard let primary else { return false }
        return primary.canStop == true && primary.measurementIdPublic != nil
    }

    static func packFacts(
        runs: [AtlasArenaLiveRun],
        primary: AtlasArenaLiveRun?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(runs: runs, primary: primary)
        facts.append("arena_live_face: \(face.productWord)")
        if runs.isEmpty {
            absences.append("nenhuma corrida publicada neste recorte")
            return (facts, absences)
        }
        facts.append("runs: \(runs.count)")
        facts.append("can_stop: \(canStop(primary: primary))")
        for run in rank(runs).prefix(6) {
            facts.append(
                "run: \(run.suite) · \(run.status.rawValue)"
            )
        }
        if let primary {
            facts.append("primary_suite: \(primary.suite)")
            facts.append("primary_status: \(primary.status.rawValue)")
        } else {
            absences.append("sem corrida primary publicada")
        }
        return (facts, absences)
    }
}
