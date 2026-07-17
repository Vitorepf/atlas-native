import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit

/// Bootstrap e activities remotas — peel de LiveActivityRemoteBridge.
extension LiveActivityRemoteBridge {
    /// Mantém os dois streams do sistema vivos desde a abertura do Atlas:
    /// 1) token para APNs iniciar uma Live Activity enquanto o app está fechado;
    /// 2) activities iniciadas remotamente, para devolver o token de update ao
    /// servidor e ligar aquele cartão ao trace real.
    func bootstrap(client: AtlasClient, installationId: String) {
        guard #available(iOS 17.2, *) else { return }
        if startTokenTask == nil {
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
        if remoteActivityTask == nil {
            remoteActivityTask = Task { @MainActor [weak self] in
                guard let self else { return }
                for await activity in Activity<AtlasTurnAttributes>.activityUpdates {
                    guard !Task.isCancelled else { break }
                    guard !self.locallyManagedActivityIDs.contains(activity.id) else { continue }
                    self.observeRemotelyStartedActivity(activity, client: client, installationId: installationId)
                }
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
