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

    func observePushTokens(
        activity: Activity<AtlasTurnAttributes>,
        model: ConversationModel,
        startedAt: Date
    ) {
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

    func end(activityID: String, model: ConversationModel?, reason: String) {
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
