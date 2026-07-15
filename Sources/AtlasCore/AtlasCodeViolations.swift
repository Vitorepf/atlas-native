import Foundation

/// Public C24 rules projection. The server is the authority for Git facts and
/// rule evaluation; native only renders the versioned result.
public struct AtlasCodeViolationsResponse: Decodable, Equatable, Sendable {
    public static let schemaVersion = "atlas.code.violations.v1"

    public let schemaVersion: String
    public let repo: String
    public let generatedAt: String
    public let violations: [AtlasCodeViolation]
    public let plan: [AtlasCodeViolationPlan]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, generatedAt, violations, plan
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
        guard schemaVersion == Self.schemaVersion else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: values,
                debugDescription: "Unsupported Atlas Code violations schema."
            )
        }
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.generatedAt = try values.decode(String.self, forKey: .generatedAt)
        self.violations = try values.decode([AtlasCodeViolation].self, forKey: .violations)
        self.plan = try values.decode([AtlasCodeViolationPlan].self, forKey: .plan)
    }
}

public struct AtlasCodeViolation: Decodable, Equatable, Sendable, Identifiable {
    public let ruleId: String
    public let target: String
    public let since: String?
    public let severity: String
    public let plan: [AtlasCodeViolationPlanStep]

    public var id: String { "\(ruleId):\(target)" }
}

public struct AtlasCodeViolationPlan: Decodable, Equatable, Sendable, Identifiable {
    public let ruleId: String
    public let target: String
    public let steps: [AtlasCodeViolationPlanStep]

    public var id: String { "\(ruleId):\(target)" }
}

public struct AtlasCodeViolationPlanStep: Decodable, Equatable, Sendable, Identifiable {
    public let action: String
    public let label: String

    public var id: String { action }
}
