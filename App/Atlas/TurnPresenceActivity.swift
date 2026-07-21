import ActivityKit
import AtlasCore
import Foundation
import SwiftUI
import UIKit
import UserNotifications

// WAVE-116 Live Activity start/update/end/broadcast

#if canImport(ActivityKit)
#endif

@MainActor
// MARK: - Broadcast / lifecycle
extension TurnPresence {
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

#if canImport(ActivityKit)
#endif

@MainActor
// MARK: - End activities
extension TurnPresence {
    func endActivities(
        key: TraceID,
        state: AtlasTurnAttributes.ContentState,
        model: ConversationModel?,
        closed: Bool
    ) {
        #if canImport(ActivityKit)
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
        #endif
    }
}

#if canImport(ActivityKit)
#endif

@MainActor
// MARK: - Finish activity
extension TurnPresence {
    func finishActivity(_ entry: Entry, presence: AtlasExecutionPresence?,
                        phaseOverride: String? = nil) {
        #if canImport(ActivityKit)
        guard let key = entry.activityKey else { return }
        let progress = entry.model?.bubbles.last(where: { $0.traceId == key })?.executionProgress
        let state = contentState(entry, presence: presence, finished: true,
                                 phaseOverride: phaseOverride, progress: progress)
        endActivities(
            key: key,
            state: state,
            model: entry.model,
            closed: phaseOverride == "sessão encerrada"
        )
        entry.activityStarted = false
        entry.activityKey = nil
        #endif
    }

}



#if canImport(ActivityKit)
#endif

@MainActor
// MARK: - Update activity
extension TurnPresence {
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
}

#if canImport(ActivityKit)
#endif

@MainActor
extension TurnPresence {

// MARK: - Start activity
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

}

@MainActor
// MARK: - Clock / timing
extension TurnPresence {
    static func clock(_ ms: Int) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}

@MainActor
extension TurnPresence {
    static func timingAnchor(
        entry: Entry,
        presence p: AtlasExecutionPresence?,
        finished: Bool
    ) -> (started: Date, paused: Bool?, pausedDisplay: String?) {
        var started = entry.startedAt
        var paused: Bool? = nil
        var pausedDisplay: String? = nil
        if let p {
            if let since = p.runningSince {
                started = since.addingTimeInterval(-Double(p.elapsedActiveMilliseconds ?? 0) / 1000)
            } else if p.isTimerPaused {
                paused = true
                pausedDisplay = p.elapsedActiveMilliseconds.map(clock)
            }
            if finished, let ms = p.elapsedActiveMilliseconds {
                pausedDisplay = clock(ms)
            }
        }
        if started > Date() { started = Date() }
        return (started, paused, pausedDisplay)
    }
}

#if canImport(ActivityKit)
#endif

@MainActor
// MARK: - Content state
extension TurnPresence {
    func contentState(_ entry: Entry, presence p: AtlasExecutionPresence?,
                      finished: Bool, phaseOverride: String? = nil,
                      progress: AtlasExecutionPlan.Progress? = nil)
        -> AtlasTurnAttributes.ContentState {
        let timing = Self.timingAnchor(entry: entry, presence: p, finished: finished)
        return AtlasTurnAttributes.ContentState(
            phaseTitle: phaseOverride ?? p?.phaseTitle ?? (finished ? "resposta pronta" : "Executando"),
            startedAt: timing.started,
            finished: finished,
            activeSessions: max(finished ? 0 : 1, activeCount),
            paused: timing.paused,
            pausedDisplay: timing.pausedDisplay,
            progressCurrent: progress?.current,
            progressTotal: progress?.total,
            queuedCount: entry.model?.queuedMessages.count)
    }
}

@MainActor
// MARK: - Live session publish
extension TurnPresence {
    func liveSessionSnapshot(from entry: Entry) -> LiveSessionSnapshot? {
        guard let model = entry.model,
              let presence = model.currentExecutionPresence,
              let trace = model.currentExecutionPresenceTraceId else { return nil }
        return LiveSessionSnapshot(
            id: trace.rawValue,
            threadId: entry.threadId ?? model.threadId,
            title: entry.threadTitle,
            phaseTitle: liveSessionPhaseTitle(model: model, trace: trace, presence: presence),
            timing: presence.timing,
            elapsedActiveMs: presence.elapsedActiveMilliseconds,
            runningSince: presence.runningSince,
            pauseTimestamp: presence.pauseTimestamp,
            startedAt: entry.startedAt,
            isRemote: false
        )
    }
}

@MainActor
extension TurnPresence {
    func liveSessionPhaseTitle(model: ConversationModel, trace: TraceID, presence: AtlasExecutionPresence) -> String {
        var phase = presence.phaseTitle
        if presence.timing == .running,
           let prog = model.bubbles.last(where: { $0.traceId == trace })?.executionProgress {
            phase = "\(prog.current)/\(prog.total) · \(prog.title)"
        }
        return phase
    }
}

@MainActor
extension TurnPresence {
    func publishLiveSessions() {
        var byTrace: [String: LiveSessionSnapshot] = [:]
        for entry in entries.values where entry.ongoing {
            guard let snap = liveSessionSnapshot(from: entry) else { continue }
            byTrace[snap.id] = snap
        }
        liveSessions = byTrace.values.sorted { $0.startedAt < $1.startedAt }
    }
}

// WAVE-102: away notification grammar → TurnPresenceJudgment (A11y soup deleted)

