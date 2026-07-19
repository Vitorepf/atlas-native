import Foundation

/// Estado público que a Arena consegue afirmar a partir do feed vivo.
///
public enum AtlasArenaLivePhase: Sendable, Equatable {
    case idle
    case queued
    case running
    case stopping
    case stopped
    case completed
    case failed
}

public struct AtlasArenaLiveProgress: Sendable, Equatable {
    public let completed: Int
    public let total: Int

    public var remaining: Int { total - completed }
    public var fraction: Double { Double(completed) / Double(total) }

    init?(run: AtlasArenaLiveRun) {
        guard let casesDone = run.casesDone,
              let casesTotal = run.casesTotal,
              casesTotal > 0 else {
            return nil
        }
        completed = min(max(0, casesDone), casesTotal)
        total = casesTotal
    }
}

/// Projeção pequena e determinística para a tela AGORA.
///
/// Ela centraliza a classificação para impedir que a UI trate todo estado
/// "não running" como fila — falha e estado futuro/desconhecido continuam
/// distintos e honestos.
public struct AtlasArenaLivePresentation: Sendable, Equatable {
    public let phase: AtlasArenaLivePhase
    public let primaryRun: AtlasArenaLiveRun?
    public let runningRuns: [AtlasArenaLiveRun]
    public let queuedRuns: [AtlasArenaLiveRun]
    public let stoppingRuns: [AtlasArenaLiveRun]
    public let stoppedRuns: [AtlasArenaLiveRun]
    public let failedRuns: [AtlasArenaLiveRun]
    public let completedRuns: [AtlasArenaLiveRun]
    public let unknownRuns: [AtlasArenaLiveRun]
    public let queuedSuites: [String]
    public let progress: AtlasArenaLiveProgress?

    init(runs: [AtlasArenaLiveRun]) {
        runningRuns = runs.filter { $0.status == .running }
        queuedRuns = runs.filter { $0.status == .queued }
        stoppingRuns = runs.filter { $0.status == .stopping }
        stoppedRuns = runs.filter { $0.status == .stopped }
        failedRuns = runs.filter { $0.status == .failed }
        completedRuns = runs.filter { $0.status == .completed }
        unknownRuns = runs.filter {
            if case .unknown = $0.status { return true }
            return false
        }

        phase = if !stoppingRuns.isEmpty {
            .stopping
        } else if !runningRuns.isEmpty {
            .running
        } else if !queuedRuns.isEmpty {
            .queued
        } else if !failedRuns.isEmpty {
            .failed
        } else if !completedRuns.isEmpty {
            .completed
        } else if !stoppedRuns.isEmpty {
            .stopped
        } else {
            .idle
        }

        primaryRun = stoppingRuns.first
            ?? runningRuns.first
            ?? queuedRuns.first
            ?? failedRuns.first
            ?? completedRuns.first
            ?? stoppedRuns.first
            ?? unknownRuns.first
        // O denominador publicado continua válido depois do terminal. A UI
        // precisa provar 42/42, 23/42 ou 18/42 sem transformar ausência em zero.
        progress = primaryRun.flatMap(AtlasArenaLiveProgress.init(run:))

        var seenSuites = Set<String>()
        queuedSuites = queuedRuns.compactMap { run in
            seenSuites.insert(run.suite).inserted ? run.suite : nil
        }
    }
}

public extension AtlasArenaLiveRuns {
    var presentation: AtlasArenaLivePresentation {
        AtlasArenaLivePresentation(runs: runs)
    }
}
