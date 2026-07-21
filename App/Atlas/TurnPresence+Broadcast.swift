import ActivityKit
import AtlasCore
import Foundation

// Cycle 038 fuse → TurnPresence+Broadcast.swift

#if canImport(ActivityKit)
#endif


@MainActor
extension TurnPresence {
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

#if canImport(ActivityKit)
#endif


@MainActor
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
