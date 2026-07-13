import Foundation

/// Contrato mínimo entre a Live Activity nativa e a execução que o Atlas
/// registrou no servidor. O `pushToken` pertence a uma atividade efêmera, não
/// ao dispositivo nem ao token de pareamento; por isso ele nunca é persistido
/// no app nem reaproveitado em outro trace.
public struct AtlasLiveActivityRegistrationInput: Codable, Sendable, Equatable {
    public let traceId: String
    public let activityId: String
    /// Identificador por instalação, persistente só no aparelho. Permite ao
    /// servidor contar sessões paralelas do MESMO Atlas sem misturar iPhones.
    public let installationId: String
    public let pushToken: String
    public let environment: Environment
    public let startedAt: Date
    public let frequentUpdatesEnabled: Bool

    public enum Environment: String, Codable, Sendable, Equatable {
        case sandbox
        case production
    }

    public init(
        traceId: String,
        activityId: String,
        installationId: String,
        pushToken: String,
        environment: Environment,
        startedAt: Date,
        frequentUpdatesEnabled: Bool
    ) {
        self.traceId = traceId
        self.activityId = activityId
        self.installationId = installationId
        self.pushToken = pushToken
        self.environment = environment
        self.startedAt = startedAt
        self.frequentUpdatesEnabled = frequentUpdatesEnabled
    }
}

/// Confirmação pública do servidor. Não contém token, prompt ou conteúdo do
/// trace: basta para o app saber que APNs poderá acompanhar esta execução.
public struct AtlasLiveActivityRegistrationReceipt: Codable, Sendable, Equatable {
    public let registrationId: String
    public let traceId: String
    public let activityId: String
    public let status: String

    public init(registrationId: String, traceId: String, activityId: String, status: String) {
        self.registrationId = registrationId
        self.traceId = traceId
        self.activityId = activityId
        self.status = status
    }
}

public struct AtlasLiveActivityInvalidationInput: Codable, Sendable, Equatable {
    public let traceId: String
    public let reason: String

    public init(traceId: String, reason: String) {
        self.traceId = traceId
        self.reason = reason
    }
}
