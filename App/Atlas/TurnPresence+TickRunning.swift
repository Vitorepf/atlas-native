import Foundation
import UIKit
import AtlasCore

// Running branch — peel de TurnPresence+Tick.

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
