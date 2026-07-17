import Foundation

/// SD-1: projeção pública mínima para qualquer superfície fora do app.
/// Widgets leem só este arquivo no App Group; ausência/versão errada falha
/// fechado para "abra o Atlas".
public struct AtlasNativeSnapshot: Codable, Sendable, Equatable {
    public static let schemaVersion = "atlas.native.snapshot.v1"
    public static let appGroupIdentifier = "group.com.vitor.atlas.native"
    public static let relativePath = "snapshot/atlas.native.snapshot.v1.json"

    public let schemaVersion: String
    public let generatedAt: Date
    public let liveSessions: [LiveSession]?
    public let fleet: Fleet?
    public let week: Week?
    public let queuedCount: Int?

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case generatedAt = "generated_at"
        case liveSessions = "live_sessions"
        case fleet
        case week
        case queuedCount = "queued_count"
    }

    public init(
        generatedAt: Date,
        liveSessions: [LiveSession]? = nil,
        fleet: Fleet? = nil,
        week: Week? = nil,
        queuedCount: Int? = nil
    ) {
        self.schemaVersion = Self.schemaVersion
        self.generatedAt = generatedAt
        self.liveSessions = liveSessions
        self.fleet = fleet
        self.week = week
        self.queuedCount = queuedCount
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Native snapshot schema.")
        generatedAt = try values.decode(Date.self, forKey: .generatedAt)
        liveSessions = try values.decodeIfPresent([LiveSession].self, forKey: .liveSessions)
        fleet = try values.decodeIfPresent(Fleet.self, forKey: .fleet)
        week = try values.decodeIfPresent(Week.self, forKey: .week)
        queuedCount = try values.decodeIfPresent(Int.self, forKey: .queuedCount)
    }

    public struct LiveSession: Codable, Sendable, Equatable, Identifiable {
        public enum Timing: String, Codable, Sendable, Equatable {
            case running
            case paused
            case finished
        }

        public var id: String { "\(title):\(phaseTitle):\(runningSince ?? "")" }

        public let title: String
        public let phaseTitle: String
        public let timing: Timing
        public let elapsedActiveMs: Int?
        public let runningSince: String?

        private enum CodingKeys: String, CodingKey {
            case title
            case phaseTitle = "phase_title"
            case timing
            case elapsedActiveMs = "elapsed_active_ms"
            case runningSince = "running_since"
        }

        public init(
            title: String,
            phaseTitle: String,
            timing: Timing,
            elapsedActiveMs: Int? = nil,
            runningSince: String? = nil
        ) {
            self.title = title
            self.phaseTitle = phaseTitle
            self.timing = timing
            self.elapsedActiveMs = elapsedActiveMs
            self.runningSince = runningSince
        }
    }

    public struct Fleet: Codable, Sendable, Equatable {
        public let scannedAt: String?
        public let incident: Incident?
        public let lastDelivery: LastDelivery?

        private enum CodingKeys: String, CodingKey {
            case scannedAt = "scanned_at"
            case incident
            case lastDelivery = "last_delivery"
        }

        public init(scannedAt: String? = nil, incident: Incident? = nil, lastDelivery: LastDelivery? = nil) {
            self.scannedAt = scannedAt
            self.incident = incident
            self.lastDelivery = lastDelivery
        }

        public struct Incident: Codable, Sendable, Equatable {
            public let present: Bool
            public let flags: [String]
            public let recommendedAction: String?

            private enum CodingKeys: String, CodingKey {
                case present
                case flags
                case recommendedAction = "recommended_action"
            }

            public init(present: Bool, flags: [String] = [], recommendedAction: String? = nil) {
                self.present = present
                self.flags = flags
                self.recommendedAction = recommendedAction
            }
        }

        public struct LastDelivery: Codable, Sendable, Equatable {
            public let title: String
            public let mergeHash: String
            public let at: String

            private enum CodingKeys: String, CodingKey {
                case title
                case mergeHash = "merge_hash"
                case at
            }

            public init(title: String, mergeHash: String, at: String) {
                self.title = title
                self.mergeHash = mergeHash
                self.at = at
            }
        }
    }

    public struct Week: Codable, Sendable, Equatable {
        public let window: String
        public let commits: Int
        public let heals: Int
        public let prevented: Int

        public init(window: String, commits: Int, heals: Int, prevented: Int) {
            self.window = window
            self.commits = commits
            self.heals = heals
            self.prevented = prevented
        }
    }
}

