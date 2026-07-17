import Foundation

/// Decode e rótulos — peel de AtlasCodeProvenance.

extension AtlasCodeProvenance {
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

    public var diffHeadline: String? {
        guard !files.isEmpty else { return nil }
        let additions = files.compactMap(\.additions).reduce(0, +)
        let deletions = files.compactMap(\.deletions).reduce(0, +)
        let noun = files.count == 1 ? "arquivo" : "arquivos"
        return "\(files.count) \(noun) · +\(additions) \u{2212}\(deletions)"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Code provenance schema.")
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.hash = try values.decode(String.self, forKey: .hash)
        self.commitMessage = try values.decode(String.self, forKey: .commitMessage)
        self.commitBody = try values.decodeIfPresent(String.self, forKey: .commitBody)
        self.authorName = try values.decode(String.self, forKey: .authorName)
        self.authorEmail = try values.decode(String.self, forKey: .authorEmail)
        self.authoredAt = try values.decode(Int.self, forKey: .authoredAt)
        self.agent = try values.decode(String.self, forKey: .agent)
        self.files = try values.decodeIfPresent([AtlasCodeFileChange].self, forKey: .files) ?? []
        self.traceId = try values.decodeIfPresent(String.self, forKey: .traceId)
        self.operatorQuote = try values.decodeIfPresent(String.self, forKey: .operatorQuote)
        self.obra = try values.decodeIfPresent([String].self, forKey: .obra)
        self.gates = try values.decodeIfPresent([String].self, forKey: .gates)
        self.traceAgent = try values.decodeIfPresent(String.self, forKey: .traceAgent)
    }
}
