import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit
#endif

// ActivityKit start/update/finish + ContentState — fora do shell TurnPresence.

@MainActor
extension TurnPresence {
    // MARK: - Live Activities (uma por sessão; contador compartilhado)
    // Activity<T> não é Sendable no Swift 6 — nunca atravessa Task. Dentro das
    // Tasks, enumeramos ESTATICAMENTE filtrando por attributes.threadKey.

    /// ContentState a partir da presença tipada — o ÚNICO relógio permitido:
    /// com timer do servidor, o timer nativo parte de (runningSince − ativo
    /// acumulado) e mostra exatamente o tempo ATIVO; pausado congela o
    /// acumulado em texto; trace legado cai na base local sem fingir pausas.
    func contentState(_ entry: Entry, presence p: AtlasExecutionPresence?,
                      finished: Bool, phaseOverride: String? = nil,
                      progress: AtlasExecutionPlan.Progress? = nil)
        -> AtlasTurnAttributes.ContentState {
        var started = entry.startedAt
        var paused: Bool? = nil
        var pausedDisplay: String? = nil
        if let p {
            if let since = p.runningSince {
                started = since.addingTimeInterval(-Double(p.elapsedActiveMilliseconds ?? 0) / 1000)
            } else if p.isTimerPaused {
                paused = true
                pausedDisplay = p.elapsedActiveMilliseconds.map(Self.clock)
            }
            if finished, let ms = p.elapsedActiveMilliseconds {
                pausedDisplay = Self.clock(ms)   // congela o total ativo no fim
            }
        }
        if started > Date() { started = Date() }
        return AtlasTurnAttributes.ContentState(
            phaseTitle: phaseOverride ?? p?.phaseTitle ?? (finished ? "resposta pronta" : "Executando"),
            startedAt: started,
            finished: finished,
            activeSessions: max(finished ? 0 : 1, activeCount),
            paused: paused,
            pausedDisplay: pausedDisplay,
            progressCurrent: progress?.current,
            progressTotal: progress?.total,
            queuedCount: entry.model?.queuedMessages.count)
    }

    static func clock(_ ms: Int) -> String {
        let s = ms / 1000
        return s >= 3600 ? String(format: "%d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
                         : String(format: "%d:%02d", s / 60, s % 60)
    }

    func startActivity(_ entry: Entry, traceId: TraceID, presence: AtlasExecutionPresence,
                       phaseOverride: String? = nil) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        entry.activityKey = traceId
        let progress = entry.model?.bubbles.last(where: { $0.traceId == traceId })?.executionProgress
        let state = contentState(entry, presence: presence, finished: false, phaseOverride: phaseOverride, progress: progress)
        guard let activity = try? Activity.request(
            attributes: AtlasTurnAttributes(threadTitle: entry.threadTitle, threadKey: traceId.rawValue),
            content: .init(state: state, staleDate: nil),
            pushType: .token
        ) else { entry.activityKey = nil; return }
        entry.activityStarted = true
        LiveActivityRemoteBridge.shared.observePushTokens(
            activity: activity,
            model: entry.model!,
            startedAt: entry.startedAt
        )
        #endif
    }

    func updateActivity(_ entry: Entry, presence: AtlasExecutionPresence,
                        phaseOverride: String? = nil) {
        #if canImport(ActivityKit)
        guard let key = entry.activityKey else { return }
        let progress = entry.model?.bubbles.last(where: { $0.traceId == key })?.executionProgress
        let state = contentState(entry, presence: presence, finished: false, phaseOverride: phaseOverride, progress: progress)
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities where a.attributes.threadKey == key.rawValue {
                await a.update(.init(state: state, staleDate: nil))
            }
        }
        #endif
    }

    func finishActivity(_ entry: Entry, presence: AtlasExecutionPresence?,
                        phaseOverride: String? = nil) {
        #if canImport(ActivityKit)
        guard let key = entry.activityKey else { return }
        let progress = entry.model?.bubbles.last(where: { $0.traceId == key })?.executionProgress
        let state = contentState(entry, presence: presence, finished: true,
                                 phaseOverride: phaseOverride, progress: progress)
        let model = entry.model
        let closed = phaseOverride == "sessão encerrada"
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities where a.attributes.threadKey == key.rawValue {
                LiveActivityRemoteBridge.shared.end(
                    activityID: a.id,
                    model: model,
                    reason: closed ? "session_closed" : "completed"
                )
                await a.end(.init(state: state, staleDate: nil),
                            dismissalPolicy: .after(.now + 4))
            }
        }
        entry.activityStarted = false
        entry.activityKey = nil
        #endif
    }

    /// Propaga o contador novo para TODAS as activities vivas, preservando a
    /// fase e o timer de cada uma (lê o estado atual e só troca o contador).
    func broadcastCount() {
        #if canImport(ActivityKit)
        let count = activeCount
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities {
                let s = a.content.state
                guard !s.finished, s.activeSessions != max(1, count) else { continue }
                var next = s
                next.activeSessions = max(1, count)   // preserva fase, timer e pausa
                await a.update(.init(state: next, staleDate: nil))
            }
        }
        #endif
    }
}
