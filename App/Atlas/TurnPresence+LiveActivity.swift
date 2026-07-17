import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit
#endif

// ActivityKit start/update — fora do shell TurnPresence.
// finish/broadcast → TurnPresence+Broadcast.swift

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
