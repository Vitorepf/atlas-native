import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit
#endif

// updateActivity — peel de TurnPresence+LiveActivity.

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
