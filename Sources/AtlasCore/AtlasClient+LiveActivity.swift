import Foundation

extension AtlasClient {
    // MARK: - Live Activities remotas (APNs)

    /// Registra o token ROTATIVO de uma ActivityKit Live Activity para o trace
    /// já criado. O servidor recebe somente o token necessário para APNs e
    /// devolve um receipt sem material sensível.
    public func registerLiveActivity(
        _ input: AtlasLiveActivityRegistrationInput
    ) async throws -> AtlasLiveActivityRegistrationReceipt {
        let response: AtlasLiveActivityRegistrationResponse = try await post(AtlasRoute.liveActivities, body: input)
        return response.registration
    }

    /// Registra/rotaciona o token que permite iniciar uma ActivityKit remota
    /// para esta instalação quando uma missão começa pelo Terminal/CLI.
    public func registerLiveActivityStartToken(
        _ input: AtlasLiveActivityStartTokenInput
    ) async throws -> AtlasLiveActivityStartTokenReceipt {
        let response: AtlasLiveActivityStartTokenResponse = try await post(
            AtlasRoute.liveActivityStartTokens, body: input
        )
        return response.registration
    }

    /// Invalida um token quando a Live Activity acaba localmente. A chamada é
    /// idempotente: falha de rede não muda a verdade local nem reativa o token.
    public func invalidateLiveActivity(
        activityId: String,
        input: AtlasLiveActivityInvalidationInput
    ) async throws -> AtlasLiveActivityRegistrationReceipt {
        let response: AtlasLiveActivityRegistrationResponse = try await post(
            AtlasRoute.liveActivityInvalidate(activityId),
            body: input
        )
        return response.registration
    }
}
