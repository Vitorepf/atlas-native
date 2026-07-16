import Foundation
import AtlasCore

@MainActor
extension ConversationModel {
    /// Pede ao servidor um recibo para outra superfície abrir esta mesma thread
    /// e sessão. Não envia conteúdo da conversa e não cria uma thread nova.
    func handoffToSurface(_ destination: AtlasAiSurfaceDestination) async {
        guard let threadId else {
            toast = "A conversa ainda não possui uma sessão canônica para continuar."
            return
        }

        do {
            latestSurfaceHandoff = try await client.handoffAiThreadSurface(
                threadId.rawValue,
                input: .init(toSurface: destination)
            ).handoff
        } catch {
            toast = "Não foi possível preparar a continuidade: \(error)"
        }
    }

    /// Ponte não visual para ActivityKit. A casca observa o `traceId` real da
    /// bolha e chama isto apenas quando receber um token de push do sistema.
    /// Não há fallback falso: sem trace ou sem token, a Live Activity permanece
    /// local e o servidor não anuncia cobertura remota.
    func registerLiveActivityPushToken(
        traceId: TraceID,
        activityId: String,
        pushToken: String,
        environment: AtlasLiveActivityRegistrationInput.Environment,
        startedAt: Date,
        frequentUpdatesEnabled: Bool
    ) async -> AtlasLiveActivityRegistrationReceipt? {
        do {
            return try await client.registerLiveActivity(.init(
                traceId: traceId.rawValue,
                activityId: activityId,
                installationId: AtlasInstallationIdentity.id,
                pushToken: pushToken,
                environment: environment,
                startedAt: startedAt,
                frequentUpdatesEnabled: frequentUpdatesEnabled
            ))
        } catch {
            // A execução e a UI não podem cair porque APNs está indisponível.
            // A cobertura será explicitamente local até o próximo token válido.
            return nil
        }
    }

    func invalidateLiveActivityPushToken(
        traceId: TraceID,
        activityId: String,
        reason: String
    ) async {
        _ = try? await client.invalidateLiveActivity(
            activityId: activityId,
            input: .init(traceId: traceId.rawValue, reason: reason)
        ) as AtlasLiveActivityRegistrationReceipt
    }
}
