import ActivityKit
import AtlasCore
import Foundation
import SwiftUI
import UIKit

// Cycle 038 fuse → TurnPresence+LiveActivityState.swift

extension TurnPresence {
    /// Um turno observado. Classe (não struct) para `weak model` no registro.
    final class Entry {
        weak var model: ConversationModel?
        var threadTitle: String
        var threadId: ThreadID?
        var activityKey: TraceID?   // trace real que liga Activity ↔ conversa
        var activityStarted = false
        var ongoing = false        // C14: running OU paused — a sessão vive
        var visible = false
        var startedAt = Date()     // base local só para trace legado (timer nil)
        init(model: ConversationModel, threadTitle: String, threadId: ThreadID?) {
            self.model = model
            self.threadTitle = threadTitle
            self.threadId = threadId
        }
    }
}

#if canImport(ActivityKit)
#endif


@MainActor
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

// ActivityKit start/update — fora do shell TurnPresence.

@MainActor
extension TurnPresence {
    // MARK: - Live Activities (uma por sessão; contador compartilhado)
    // Activity<T> não é Sendable no Swift 6 — nunca atravessa Task. Dentro das
    // Tasks, enumeramos ESTATICAMENTE filtrando por attributes.threadKey.

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
extension TurnPresence {
    /// ContentState a partir da presença tipada — o ÚNICO relógio permitido:
    /// com timer do servidor, o timer nativo parte de (runningSince − ativo
    /// acumulado) e mostra exatamente o tempo ATIVO; pausado congela o
    /// acumulado em texto; trace legado cai na base local sem fingir pausas.
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
    /// Reconstrói `liveSessions` a partir das entries ongoing. Dedup por
    /// traceId; conversa nova sem thread canônica fica sem navegação.
    func publishLiveSessions() {
        var byTrace: [String: LiveSessionSnapshot] = [:]
        for entry in entries.values where entry.ongoing {
            guard let snap = liveSessionSnapshot(from: entry) else { continue }
            byTrace[snap.id] = snap
        }
        liveSessions = byTrace.values.sorted { $0.startedAt < $1.startedAt }
    }
}

@MainActor
extension TurnPresence {
    func tick(_ id: ObjectIdentifier) {
        guard let entry = entries[id] else { return }
        guard let model = entry.model else { cleanup(id); return }
        let presence = model.currentExecutionPresence
        let trace = model.currentExecutionPresenceTraceId

        if let p = presence, let trace {
            var phase: String? = nil
            if p.timing == .running,
               let prog = model.bubbles.last(where: { $0.traceId == trace })?.executionProgress {
                phase = "\(prog.current)/\(prog.total) · \(prog.title)"
            }
            tickRunning(entry, model: model, trace: trace, presence: p, phase: phase)
        } else if entry.ongoing {
            tickFinished(entry, model: model)
        }
    }
}

@MainActor
extension TurnPresence {
    func tickFinished(_ entry: Entry, model: ConversationModel) {
        entry.ongoing = false
        let traceKey = entry.activityKey
        let final = lastPresence(model, key: traceKey)
        finishActivity(entry, presence: final)
        broadcastCount()
        if UIApplication.shared.applicationState == .active, !entry.visible {
            AtlasMotion.softImpact(reduceMotion: UIAccessibility.isReduceMotionEnabled)
        }
        Task { @MainActor in
            await requestPermissionOnce()
            notifyIfAway(entry, model: model, finalPresence: final, traceId: traceKey)
        }
        syncRunning()
    }

    /// A presença final da bolha dona da Activity (fase "Concluído"/"Falhou").
    func lastPresence(_ model: ConversationModel, key: TraceID?) -> AtlasExecutionPresence? {
        guard let key else { return nil }
        return model.bubbles.last(where: { $0.traceId == key })?.executionPresence
    }
}

@MainActor
extension TurnPresence {
    func tickRunning(_ entry: Entry, model: ConversationModel, trace: TraceID,
                     presence p: AtlasExecutionPresence, phase: String?) {
        if entry.activityKey != nil && entry.activityKey != trace {
            finishActivity(entry, presence: lastPresence(model, key: entry.activityKey))
        }
        if !entry.ongoing || !entry.activityStarted {
            if !entry.ongoing { entry.startedAt = Date() }
            entry.ongoing = true
            startActivity(entry, traceId: trace, presence: p, phaseOverride: phase)
            broadcastCount()
            syncRunning()
        } else {
            updateActivity(entry, presence: p, phaseOverride: phase)
        }
    }
}

extension TurnPresence {
    /// Model desalocado (conversa fechada): encerra a activity órfã com honestidade.
    func cleanup(_ id: ObjectIdentifier) {
        guard let entry = entries.removeValue(forKey: id) else { return }
        if entry.ongoing { finishActivity(entry, presence: nil, phaseOverride: "sessão encerrada") }
        broadcastCount()
        syncRunning()
    }
}

extension TurnPresence {
    func observe(_ id: ObjectIdentifier) {
        guard let entry = entries[id], let model = entry.model else {
            cleanup(id); return
        }
        withObservationTracking {
            _ = model.currentExecutionPresenceTraceId
            _ = model.currentExecutionPresence?.phaseTitle
            _ = model.currentExecutionPresence?.timing
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.tick(id)
                self?.observe(id)
            }
        }
    }
}

extension TurnPresence {
    func watch(_ model: ConversationModel, threadTitle: String, threadId: ThreadID? = nil) {
        let id = ObjectIdentifier(model)
        if let existing = entries[id] {
            existing.threadTitle = threadTitle
            existing.threadId = threadId ?? model.threadId
            publishLiveSessions()
            return
        }
        let entry = Entry(model: model, threadTitle: threadTitle, threadId: threadId ?? model.threadId)
        entries[id] = entry
        observe(id)
    }

    func setVisible(_ model: ConversationModel, visible: Bool) {
        entries[ObjectIdentifier(model)]?.visible = visible
    }
}
