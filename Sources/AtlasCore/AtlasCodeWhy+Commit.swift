import Foundation

/// H1 · File-level biography commit row — peel de AtlasCodeWhy.
extension AtlasCodeWhy {
    public struct Commit: Decodable, Sendable, Equatable, Identifiable {
        public struct Provenance: Decodable, Sendable, Equatable {
            public let quote: String
            public let obra: String?
            public let gates: [String]

            private enum CodingKeys: String, CodingKey {
                case quote, obra, gates
            }

            public init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                quote = try values.decode(String.self, forKey: .quote)
                obra = try values.decodeIfPresent(String.self, forKey: .obra)
                gates = try values.decodeIfPresent([String].self, forKey: .gates) ?? []
                if quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    throw DecodingError.dataCorruptedError(forKey: .quote, in: values, debugDescription: "Provenance quote is required.")
                }
            }
        }

        public let hash: String
        public let when: Date?
        public let agent: String
        public let subject: String
        public let provenance: Provenance?

        public var id: String { hash }

        public var shortHash: String { String(hash.prefix(7)) }

        public var agentLabel: String {
            switch agent {
            case "voce": return "você"
            case "autonomo:desconhecido": return "autônomo não identificado"
            default:
                return agent.hasPrefix("autonomo:")
                    ? "autônomo \(agent.dropFirst("autonomo:".count))"
                    : agent
            }
        }

        private enum CodingKeys: String, CodingKey {
            case hash, when, agent, subject, provenance
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            hash = try values.decode(String.self, forKey: .hash)
            when = AtlasTime.date(try values.decodeIfPresent(String.self, forKey: .when))
            agent = try values.decode(String.self, forKey: .agent)
            subject = try values.decode(String.self, forKey: .subject)
            provenance = try values.decodeIfPresent(Provenance.self, forKey: .provenance)
            if hash.isEmpty || agent.isEmpty || subject.isEmpty {
                throw DecodingError.dataCorruptedError(forKey: .hash, in: values, debugDescription: "Commit hash, agent and subject are required.")
            }
        }
    }
}
