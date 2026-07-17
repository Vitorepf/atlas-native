import Foundation

public struct AtlasAiSessionsLiveResponse: Decodable, Sendable, Equatable {
    public static let schemaVersion = "atlas.ai.sessions.live.v1"

    public let schemaVersion: String
    public let count: Int
    public let sessions: [AtlasAiLiveSession]
    public let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case schemaVersion, count, sessions, generatedAt
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(
            Self.schemaVersion,
            forKey: .schemaVersion,
            message: "Unsupported Atlas AI live sessions schema."
        )
        count = try values.decode(Int.self, forKey: .count)
        sessions = try values.decodeIfPresent([AtlasAiLiveSession].self, forKey: .sessions) ?? []
        generatedAt = try values.decodeIfPresent(String.self, forKey: .generatedAt)

        guard count == sessions.count else {
            throw DecodingError.dataCorruptedError(
                forKey: .count,
                in: values,
                debugDescription: "Live sessions count does not match sessions."
            )
        }
    }
}

public struct AtlasAiLiveSession: Decodable, Sendable, Equatable, Identifiable {
    public var id: String { threadId?.rawValue ?? title ?? phaseTitle ?? "remote-live-session" }

    public let threadId: ThreadID?
    public let title: String?
    public let phaseTitle: String?
    public let timing: AtlasAiLiveSessionTiming?
    public let elapsedActiveMs: Int?
    public let runningSince: String?

    enum CodingKeys: String, CodingKey {
        case threadId, title, phaseTitle, timing, elapsedActiveMs, runningSince
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        threadId = try values.decodeIfPresent(ThreadID.self, forKey: .threadId)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        phaseTitle = try values.decodeIfPresent(String.self, forKey: .phaseTitle)
        timing = try values.decodeIfPresent(AtlasAiLiveSessionTiming.self, forKey: .timing)

        if let elapsed = try values.decodeIfPresent(Int.self, forKey: .elapsedActiveMs) {
            guard elapsed >= 0 else {
                throw DecodingError.dataCorruptedError(
                    forKey: .elapsedActiveMs,
                    in: values,
                    debugDescription: "Live session elapsed_active_ms must be non-negative."
                )
            }
            elapsedActiveMs = elapsed
        } else {
            elapsedActiveMs = nil
        }

        if let runningSince = try values.decodeIfPresent(String.self, forKey: .runningSince) {
            guard AtlasTime.date(runningSince) != nil else {
                throw DecodingError.dataCorruptedError(
                    forKey: .runningSince,
                    in: values,
                    debugDescription: "Live session running_since must be a valid timestamp."
                )
            }
            self.runningSince = runningSince
        } else {
            self.runningSince = nil
        }
    }

    public var runningSinceDate: Date? {
        AtlasTime.date(runningSince)
    }
}

public enum AtlasAiLiveSessionTiming: String, Codable, Sendable, Equatable {
    case running
    case paused
    case finished
}

public extension AtlasClient {
    func getAiSessionsLive(installation: String) async throws -> AtlasAiSessionsLiveResponse {
        try await get(AtlasRoute.aiSessionsLive(installation: installation))
    }
}
