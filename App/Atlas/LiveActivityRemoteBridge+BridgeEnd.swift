import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit

/// End + invalidate — peel de LiveActivityRemoteBridge.

extension LiveActivityRemoteBridge {
    func end(activityID: String, model: ConversationModel?, reason: String) {
        locallyManagedActivityIDs.remove(activityID)
        tokenTasks[activityID]?.cancel()
        tokenTasks[activityID] = nil
        guard let traceId = tracesByActivityID.removeValue(forKey: activityID), let model else { return }
        Task { @MainActor in
            await model.invalidateLiveActivityPushToken(
                traceId: traceId,
                activityId: activityID,
                reason: reason
            )
        }
    }
}
#endif
