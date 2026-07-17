import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit
#endif

// finish + broadcastCount — peel de TurnPresence+LiveActivity.

@MainActor
extension TurnPresence {
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

}
