import Foundation
import UIKit
import AtlasCore

// Terminal branch — peel de TurnPresence+Tick.

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
