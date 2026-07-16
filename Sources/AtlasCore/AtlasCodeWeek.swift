import Foundation

/// Public E5 weekly projection. Every number is read from Git or ledger data;
/// notification preference is explicit and off by default.
public struct AtlasCodeWeek: Decodable, Equatable, Sendable {
    public static let schemaVersion = "atlas.code.week.v1"

    public let schemaVersion: String
    public let repo: String
    public let window: String
    public let commits: Int
    public let heals: Int
    public let prevented: Int
    public let byAgent: [String: Int]
    public let notifications: AtlasCodeNotificationPreference

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, window, commits, heals, prevented, byAgent, notifications
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
        guard schemaVersion == Self.schemaVersion else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: values,
                debugDescription: "Unsupported Atlas Code week schema."
            )
        }
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.window = try values.decode(String.self, forKey: .window)
        self.commits = try values.decode(Int.self, forKey: .commits)
        self.heals = try values.decode(Int.self, forKey: .heals)
        self.prevented = try values.decode(Int.self, forKey: .prevented)
        self.byAgent = try values.decode([String: Int].self, forKey: .byAgent)
        self.notifications = try values.decode(AtlasCodeNotificationPreference.self, forKey: .notifications)
    }
}

public struct AtlasCodeNotificationPreference: Decodable, Equatable, Sendable {
    public let enabled: Bool
    public let reason: String?
}
