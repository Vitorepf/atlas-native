import Foundation

/// Public C25 receipt projection. No approval action exists in this contract;
/// the only reversible control is the server-governed undo.
public struct AtlasCodeHealResponse: Decodable, Equatable, Sendable {
    public static let schemaVersion = "atlas.code.heals.v1"

    public let schemaVersion: String
    public let repo: String
    public let generatedAt: String
    public let mode: String
    public let violations: [AtlasCodeViolation]
    public let plan: [AtlasCodeViolationPlan]
    public let healId: String?
    public let blocked: String?
    public let stepReceipts: [AtlasCodeHealStepReceipt]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, generatedAt, mode, violations, plan
        case healId, blocked, stepReceipts
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
        guard schemaVersion == Self.schemaVersion else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: values,
                debugDescription: "Unsupported Atlas Code heal schema."
            )
        }
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.generatedAt = try values.decode(String.self, forKey: .generatedAt)
        self.mode = try values.decode(String.self, forKey: .mode)
        self.violations = try values.decode([AtlasCodeViolation].self, forKey: .violations)
        self.plan = try values.decode([AtlasCodeViolationPlan].self, forKey: .plan)
        self.healId = try values.decodeIfPresent(String.self, forKey: .healId)
        self.blocked = try values.decodeIfPresent(String.self, forKey: .blocked)
        self.stepReceipts = try values.decodeIfPresent([AtlasCodeHealStepReceipt].self, forKey: .stepReceipts) ?? []
    }
}

public struct AtlasCodeHealStepReceipt: Decodable, Equatable, Sendable, Identifiable {
    public let step: String
    public let action: String
    public let ruleId: String?
    public let target: String?
    public let status: String
    public let result: String
    public let undoRef: [String: String]?
    public let undoExpiresAt: String?

    public var id: String { "\(step):\(action):\(status)" }

    private enum CodingKeys: String, CodingKey {
        case step, action, ruleId, target, status, result, undoRef, undoExpiresAt
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let number = try? values.decode(Int.self, forKey: .step) {
            self.step = String(number)
        } else {
            self.step = try values.decode(String.self, forKey: .step)
        }
        self.action = try values.decode(String.self, forKey: .action)
        self.ruleId = try values.decodeIfPresent(String.self, forKey: .ruleId)
        self.target = try values.decodeIfPresent(String.self, forKey: .target)
        self.status = try values.decode(String.self, forKey: .status)
        self.result = try values.decode(String.self, forKey: .result)
        self.undoRef = try values.decodeIfPresent([String: String].self, forKey: .undoRef)
        self.undoExpiresAt = try values.decodeIfPresent(String.self, forKey: .undoExpiresAt)
    }
}
