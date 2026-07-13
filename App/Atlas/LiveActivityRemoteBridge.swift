import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit

/// Transporte APNs de uma Live Activity já iniciada na tela local.
///
/// A ponte é propositalmente cega para texto da resposta e raciocínio: só
/// registra o token rotativo que o próprio iOS forneceu, associado ao `trace`
/// real da conversa. Sem token ou sem trace, o app segue em modo local — não
/// há indicador de cobertura remota inventado.
@MainActor
final class LiveActivityRemoteBridge {
    static let shared = LiveActivityRemoteBridge()
    private init() {}

    private var tokenTasks: [String: Task<Void, Never>] = [:]
    private var tracesByActivityID: [String: String] = [:]
    private var locallyManagedActivityIDs: Set<String> = []
    private var startTokenTask: Task<Void, Never>?
    private var remoteActivityTask: Task<Void, Never>?

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

                // Só guarda a associação após receipt do servidor. Isso evita
                // tentar invalidar no fim um registro que nunca existiu.
                self.tracesByActivityID[activity.id] = receipt.traceId
            }
        }
    }

    private func observeRemotelyStartedActivity(
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
                    self.tracesByActivityID[activity.id] = traceId
                }
            }
        }
    }

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

    private func waitForTrace(_ model: ConversationModel) async -> String? {
        // O token APNs pode chegar antes da criação remota devolver o
        // trace. Esperamos pouco e somente enquanto aquele turno existe.
        for _ in 0..<30 {
            if let traceId = model.currentStreamingTraceId { return traceId }
            guard model.isSending else { return nil }
            try? await Task.sleep(for: .milliseconds(100))
        }
        return nil
    }

    private static var environment: AtlasLiveActivityRegistrationInput.Environment {
        #if DEBUG
        .sandbox
        #else
        .production
        #endif
    }
}

private extension Data {
    var atlasHex: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
#endif
