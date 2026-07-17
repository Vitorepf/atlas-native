import Foundation

/// Start token DTOs — peel de AtlasLiveActivity.

public struct AtlasLiveActivityStartTokenInput: Codable, Sendable, Equatable {
    public let installationId: String
    public let pushToken: String
    public let environment: AtlasLiveActivityRegistrationInput.Environment

    public init(installationId: String, pushToken: String, environment: AtlasLiveActivityRegistrationInput.Environment) {
        self.installationId = installationId
        self.pushToken = pushToken
        self.environment = environment
    }
}

public struct AtlasLiveActivityStartTokenReceipt: Codable, Sendable, Equatable {
    public let registrationId: String
    public let installationId: String
    public let status: String

    private enum CodingKeys: String, CodingKey {
        case registrationId = "id"
        case installationId
        case status
    }
}

public struct AtlasLiveActivityStartTokenResponse: Codable, Sendable, Equatable {
    public let registration: AtlasLiveActivityStartTokenReceipt
}
