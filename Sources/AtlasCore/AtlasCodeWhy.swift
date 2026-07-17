import Foundation

/// H1 · File-level biography. The server owns Git and provenance lookup; the
/// app only decodes the versioned, provider-safe projection.
public struct AtlasCodeWhy: Decodable, Sendable, Equatable {
    public static let schemaVersion = "atlas.code.why.v1"

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
