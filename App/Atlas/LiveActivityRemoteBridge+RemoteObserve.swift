import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit

/// Remote activity updates — peel de LiveActivityRemoteBridge+Remote.

extension LiveActivityRemoteBridge {
    func bootstrapRemoteActivities(client: AtlasClient, installationId: String) {
        guard #available(iOS 17.2, *), remoteActivityTask == nil else { return }
        remoteActivityTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await activity in Activity<AtlasTurnAttributes>.activityUpdates {
                guard !Task.isCancelled else { break }
                guard !self.locallyManagedActivityIDs.contains(activity.id) else { continue }
                self.observeRemotelyStartedActivity(activity, client: client, installationId: installationId)
            }
        }
    }

    func observeRemotelyStartedActivity(
        _ activity: Activity<AtlasTurnAttributes>,
        client: AtlasClient,
        installationId: String
    ) {
        tokenTasks[activity.id]?.cancel()
        tokenTasks[activity.id] = Task { @MainActor [weak self] in
            guard let self else { return }
            let traceId = activity.attributes.threadKey
            for await token in activity.pushTokenUpdates {
                guard !Task.isCancelled else { break }
                let receipt = try? await client.registerLiveActivity(.init(
                    traceId: traceId,
                    activityId: activity.id,
                    installationId: installationId,
                    pushToken: token.atlasHex,
                    environment: Self.environment,
                    startedAt: activity.content.state.startedAt,
                    frequentUpdatesEnabled: ActivityAuthorizationInfo().frequentPushesEnabled
                ))
                if receipt != nil {
                    self.tracesByActivityID[activity.id] = TraceID(traceId)
                }
            }
        }
    }
}
#endif
