import ActivityKit
import AtlasCore
import Foundation

// Cycle 040 fuse → LiveActivityRemoteBridge+RemoteBootstrap.swift

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
