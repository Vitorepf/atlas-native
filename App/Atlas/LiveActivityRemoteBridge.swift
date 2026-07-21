import ActivityKit
import AtlasCore
import Foundation

// IDLE-COMPRESS fused

#if canImport(ActivityKit)

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

#if canImport(ActivityKit)

extension LiveActivityRemoteBridge {
    func observePushTokens(
        activity: Activity<AtlasTurnAttributes>,
        model: ConversationModel,
        startedAt: Date
    ) {
        locallyManagedActivityIDs.insert(activity.id)
        tokenTasks[activity.id]?.cancel()
        tokenTasks[activity.id] = Task { @MainActor [weak self, weak model] in
            guard let self, let model else { return }
            for await token in activity.pushTokenUpdates {
                guard !Task.isCancelled,
                      let traceId = await self.waitForTrace(model),
                      let receipt = await model.registerLiveActivityPushToken(
                        traceId: traceId,
                        activityId: activity.id,
                        pushToken: token.atlasHex,
                        environment: Self.environment,
                        startedAt: startedAt,
                        frequentUpdatesEnabled: ActivityAuthorizationInfo().frequentPushesEnabled
                      )
                else { continue }

                self.tracesByActivityID[activity.id] = TraceID(receipt.traceId)
            }
        }
    }
}
#endif

#if canImport(ActivityKit)

extension LiveActivityRemoteBridge {
    func waitForTrace(_ model: ConversationModel) async -> TraceID? {
        for _ in 0..<30 {
            if let traceId = model.currentStreamingTraceId { return traceId }
            guard model.isSending else { return nil }
            try? await Task.sleep(for: .milliseconds(100))
        }
        return nil
    }

    static var environment: AtlasLiveActivityRegistrationInput.Environment {
        #if DEBUG
        .sandbox
        #else
        .production
        #endif
    }
}
#endif

#if canImport(ActivityKit)
extension Data {
    var atlasHex: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
#endif

#if canImport(ActivityKit)

extension LiveActivityRemoteBridge {
    func bootstrap(client: AtlasClient, installationId: String) {
        bootstrapStartToken(client: client, installationId: installationId)
        bootstrapRemoteActivities(client: client, installationId: installationId)
    }
}
#endif

#if canImport(ActivityKit)

extension LiveActivityRemoteBridge {
    func bootstrapStartToken(client: AtlasClient, installationId: String) {
        guard #available(iOS 17.2, *), startTokenTask == nil else { return }
        startTokenTask = Task { @MainActor [weak self] in
            guard self != nil else { return }
            for await token in Activity<AtlasTurnAttributes>.pushToStartTokenUpdates {
                guard !Task.isCancelled else { break }
                _ = try? await client.registerLiveActivityStartToken(.init(
                    installationId: installationId,
                    pushToken: token.atlasHex,
                    environment: Self.environment
                ))
            }
        }
    }
}
#endif

#if canImport(ActivityKit)

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

#if canImport(ActivityKit)

@MainActor
final class LiveActivityRemoteBridge {
    static let shared = LiveActivityRemoteBridge()
    private init() {}

    var tokenTasks: [String: Task<Void, Never>] = [:]
    var tracesByActivityID: [String: TraceID] = [:]
    var locallyManagedActivityIDs: Set<String> = []
    var startTokenTask: Task<Void, Never>?
    var remoteActivityTask: Task<Void, Never>?
}
#endif
