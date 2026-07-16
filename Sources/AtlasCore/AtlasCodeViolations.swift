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
    /// A trunk REAL deste repositório, dita pelo servidor.
    ///
    /// A tela escrevia "desvios da main" na mão, e metade da frota não tem
    /// main: a trunk do nivor-back-end é `production`. Dizer "desvio da main"
    /// sobre um repositório sem main é a tela afirmando com segurança uma coisa
    /// que não existe — e o operador conferindo no git não acha o que ela citou.
    ///
    /// Ausente = trunk ambígua (o servidor recusa o chute) ou servidor antigo:
    /// aí a frase fala de "desvio" sem nomear a linha, que é o que se sabe.
    public let trunk: String?

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, repo, generatedAt, violations, plan, trunk
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Code violations schema.")
        self.schemaVersion = schemaVersion
        self.repo = try values.decode(String.self, forKey: .repo)
        self.generatedAt = try values.decode(String.self, forKey: .generatedAt)
        self.violations = try values.decode([AtlasCodeViolation].self, forKey: .violations)
        self.plan = try values.decode([AtlasCodeViolationPlan].self, forKey: .plan)
        self.trunk = try values.decodeIfPresent(String.self, forKey: .trunk)
    }
}

public struct AtlasCodeViolation: Decodable, Equatable, Sendable, Identifiable {
    public let ruleId: String
    public let target: String
    public let since: String?
    public let severity: String
    public let plan: [AtlasCodeViolationPlanStep]
    /// O documento canônico que sustenta a acusação.
    ///
    /// O contrato C24 promete `rule_canon_ref` desde o começo e o servidor o
    /// manda; o app não tinha o campo, e a lei morria no fio. Acusar sem citar
    /// a lei é o pior silêncio de uma ferramenta de governança: "está errado
    /// porque sim" não é governança, é autoridade sem prova.
    ///
    /// Ausente quando a regra ainda não tem lei escrita — e isso é dito, não
    /// preenchido com um caminho plausível.
    public let ruleCanonRef: String?

    private enum CodingKeys: String, CodingKey {
        case ruleId, target, since, severity, plan, ruleCanonRef
    }

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
