import Foundation

/// H1 · File-level biography. The server owns Git and provenance lookup; the
/// app only decodes the versioned, provider-safe projection.
public struct AtlasCodeWhy: Decodable, Sendable, Equatable {
    public static let schemaVersion = "atlas.code.why.v1"

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

    public let schemaVersion: String
    public let repo: String
    public let file: String
    public let commitsTotal: Int
    public let truncated: Bool
    public let commits: [Commit]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, file, commitsTotal, truncated, commits
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Code why schema.")
        repo = try values.decode(String.self, forKey: .repo)
        file = try values.decode(String.self, forKey: .file)
        commitsTotal = try values.decode(Int.self, forKey: .commitsTotal)
        truncated = try values.decode(Bool.self, forKey: .truncated)
        commits = try values.decode([Commit].self, forKey: .commits)
        if repo.isEmpty || file.isEmpty || commitsTotal < 0 || commits.count > commitsTotal {
            throw DecodingError.dataCorruptedError(forKey: .commitsTotal, in: values, debugDescription: "Invalid file biography invariants.")
        }
    }
}

extension AtlasClient {
    /// H1 · why this file exists, from `git log --follow` + C23 provenance.
    public func getCodeWhy(repo: String, file: String, limit: Int = 20) async throws -> AtlasCodeWhy {
        let query = atlasQueryString([
            ("repo", .string(repo)),
            ("file", .string(file)),
            ("limit", .int(limit)),
        ])
        return try await get("\(AtlasRoute.codeWhy)\(query)")
    }
}
