import Foundation

extension AtlasNativeSnapshot {
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
