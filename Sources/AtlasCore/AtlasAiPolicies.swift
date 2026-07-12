import Foundation

// Catálogo de políticas / domínios / flows do Atlas AI, portado de
// lib/api/atlasAi.ts (§648-844 + métodos §1700-1724). Superfície admin: o
// registry de profiles, o catálogo de domínios/flows/orchestrators, o preview
// de política efetiva e os PATCHes de domain/flow profile.
//
// O decoder usa `.convertFromSnakeCase`, então snake_case do servidor vira
// camelCase aqui sem CodingKeys. Campo que o servidor pode omitir/mandar `null`
// é opcional — senão o decode quebra. Uniões abertas (status/maturity/autonomy)
// ficam `String`. Bags `Record<string, unknown>` viram `JSONObject?`.

// MARK: - Profile registry (getAiPolicyProfiles)

public struct AtlasAiDomainProfile: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let label: String
    public let status: String
    public let defaultFlow: String?
    public let orchestrator: String?
    public let runtimeFamily: String?
    public let description: String?
    public let autonomyDefault: String?
    public let backgroundAllowed: Bool?
    public let modelPolicy: JSONObject?
    public let contextPolicy: JSONObject?
    public let skillPolicy: JSONObject?
    public let toolPolicy: JSONObject?
    public let memoryPolicy: JSONObject?
    public let gatePolicy: JSONObject?
    public let metadata: JSONObject?
}

public struct AtlasAiFlowProfile: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let domainId: String
    public let label: String
    public let status: String
    public let orchestrator: String?
    public let runtime: String?
    public let description: String?
    public let autonomy: String?
    public let backgroundAllowed: Bool?
    public let requiresHumanApprovalForDestructive: Bool?
    public let modelPolicy: JSONObject?
    public let contextPolicy: JSONObject?
    public let skillPolicy: JSONObject?
    public let toolPolicy: JSONObject?
    public let memoryPolicy: JSONObject?
    public let gatePolicy: JSONObject?
    public let executionPolicy: JSONObject?
    public let metadata: JSONObject?
}

public struct AtlasAiPolicyProfileRegistry: Codable, Sendable {
    public let schemaVersion: Int
    public let source: String
    public let domains: [AtlasAiDomainProfile]
    public let flows: [AtlasAiFlowProfile]
}

public struct AtlasAiPolicyProfilesResponse: Codable, Sendable {
    public let generatedAt: String?
    public let profileRegistry: AtlasAiPolicyProfileRegistry
}

// MARK: - Domain catalog (getAiDomainCatalog)

public struct AtlasAiDomainCatalogOnboarding: Codable, Sendable {
    public let status: String
    public let completedCount: Int
    public let totalCount: Int
    public let completedPhases: [String]
    public let missingPhases: [String]
}

public struct AtlasAiDomainCatalogDomain: Codable, Sendable, Identifiable {
    public let id: String
    public let label: String
    public let defaultFlow: String
    public let orchestrator: String
    public let orchestratorMaturity: String
    public let runtimeFamily: String
    public let autonomyDefault: String
    public let backgroundAllowed: Bool
    public let flowCount: Int
    public let onboarding: AtlasAiDomainCatalogOnboarding
}

public struct AtlasAiDomainCatalogFlow: Codable, Sendable, Identifiable {
    public let id: String
    public let domainId: String
    public let label: String
    public let runtime: String
    public let orchestrator: String
    public let orchestratorMaturity: String
    public let autonomy: String
    public let backgroundAllowed: Bool
    public let destructiveRequiresApproval: Bool
    public let executorPreference: String
}

public struct AtlasAiDomainCatalogOrchestrator: Codable, Sendable, Identifiable {
    public let id: String
    public let `class`: String
    public let maturity: String
    public let implementedContract: Bool
    public let domains: [String]
    public let flows: [String]
}

// Objetos inline do AtlasAiDomainCatalogResponse (filters / summary / validation).
public struct AtlasAiDomainCatalogFilters: Codable, Sendable {
    public let domain: String?
    public let flow: String?
    public let maturity: String?
}

public struct AtlasAiDomainCatalogSummary: Codable, Sendable {
    public let domains: Int
    public let flows: Int
    public let orchestrators: Int
    public let implementedOrchestrators: Int
    public let scaffoldOrchestrators: Int
    public let plannedOrchestrators: Int
    public let readyDomains: Int
    public let executableIncompleteDomains: Int
}

public struct AtlasAiDomainCatalogValidation: Codable, Sendable {
    public let valid: Bool
    public let errors: [String]
    public let warnings: [String]
}

public struct AtlasAiDomainCatalogResponse: Codable, Sendable {
    public let schemaVersion: Int
    public let status: String
    public let source: String
    public let filters: AtlasAiDomainCatalogFilters
    public let summary: AtlasAiDomainCatalogSummary
    public let domains: [AtlasAiDomainCatalogDomain]
    public let flows: [AtlasAiDomainCatalogFlow]
    public let orchestrators: [AtlasAiDomainCatalogOrchestrator]
    public let validation: AtlasAiDomainCatalogValidation
    public let generatedAt: String
}

/// Query params de `getAiDomainCatalog` (maturity é união aberta -> String).
public struct AtlasAiDomainCatalogParams: Sendable {
    public var domain: String?
    public var flow: String?
    public var maturity: String?

    public init(domain: String? = nil, flow: String? = nil, maturity: String? = nil) {
        self.domain = domain
        self.flow = flow
        self.maturity = maturity
    }
}

// MARK: - Policy preview (previewAiPolicy)

public struct AtlasAiPolicyPreviewResponse: Codable, Sendable {
    public let generatedAt: String?
    public let profile: JSONObject?
    public let effectivePolicy: JSONObject?
    public let policyMergeReceipt: JSONObject?
    public let legacyPolicy: JSONObject?
}

public struct AtlasAiPolicyPreviewInput: Encodable, Sendable {
    public var profileId: String?
    public var surface: String?
    public var mode: String?
    public var task: String?
    public var payload: JSONObject?
    public var aiPolicyOverride: JSONObject?

    public init(
        profileId: String? = nil,
        surface: String? = nil,
        mode: String? = nil,
        task: String? = nil,
        payload: JSONObject? = nil,
        aiPolicyOverride: JSONObject? = nil
    ) {
        self.profileId = profileId
        self.surface = surface
        self.mode = mode
        self.task = task
        self.payload = payload
        self.aiPolicyOverride = aiPolicyOverride
    }
}

// MARK: - Profile patches (updateAiDomainProfile / updateAiFlowProfile)
// Partial<Pick<...>> -> todo campo opcional. JSONEncoder omite nil, então só os
// campos setados vão no PATCH. ponytail: Optional não distingue "não mexer" de
// "limpar pra null"; se precisar zerar um campo pra null, use o body free-form
// [String: JSONValue] via self.patch direto — upgrade quando aparecer o caso.

public struct AtlasAiDomainProfilePatch: Encodable, Sendable {
    public var label: String?
    public var status: String?
    public var defaultFlow: String?
    public var orchestrator: String?
    public var runtimeFamily: String?
    public var description: String?
    public var autonomyDefault: String?
    public var backgroundAllowed: Bool?
    public var modelPolicy: JSONObject?
    public var contextPolicy: JSONObject?
    public var skillPolicy: JSONObject?
    public var toolPolicy: JSONObject?
    public var memoryPolicy: JSONObject?
    public var gatePolicy: JSONObject?
    public var metadata: JSONObject?

    public init(
        label: String? = nil,
        status: String? = nil,
        defaultFlow: String? = nil,
        orchestrator: String? = nil,
        runtimeFamily: String? = nil,
        description: String? = nil,
        autonomyDefault: String? = nil,
        backgroundAllowed: Bool? = nil,
        modelPolicy: JSONObject? = nil,
        contextPolicy: JSONObject? = nil,
        skillPolicy: JSONObject? = nil,
        toolPolicy: JSONObject? = nil,
        memoryPolicy: JSONObject? = nil,
        gatePolicy: JSONObject? = nil,
        metadata: JSONObject? = nil
    ) {
        self.label = label
        self.status = status
        self.defaultFlow = defaultFlow
        self.orchestrator = orchestrator
        self.runtimeFamily = runtimeFamily
        self.description = description
        self.autonomyDefault = autonomyDefault
        self.backgroundAllowed = backgroundAllowed
        self.modelPolicy = modelPolicy
        self.contextPolicy = contextPolicy
        self.skillPolicy = skillPolicy
        self.toolPolicy = toolPolicy
        self.memoryPolicy = memoryPolicy
        self.gatePolicy = gatePolicy
        self.metadata = metadata
    }
}

public struct AtlasAiFlowProfilePatch: Encodable, Sendable {
    public var label: String?
    public var status: String?
    public var orchestrator: String?
    public var runtime: String?
    public var description: String?
    public var autonomy: String?
    public var backgroundAllowed: Bool?
    public var requiresHumanApprovalForDestructive: Bool?
    public var modelPolicy: JSONObject?
    public var contextPolicy: JSONObject?
    public var skillPolicy: JSONObject?
    public var toolPolicy: JSONObject?
    public var memoryPolicy: JSONObject?
    public var gatePolicy: JSONObject?
    public var executionPolicy: JSONObject?
    public var metadata: JSONObject?

    public init(
        label: String? = nil,
        status: String? = nil,
        orchestrator: String? = nil,
        runtime: String? = nil,
        description: String? = nil,
        autonomy: String? = nil,
        backgroundAllowed: Bool? = nil,
        requiresHumanApprovalForDestructive: Bool? = nil,
        modelPolicy: JSONObject? = nil,
        contextPolicy: JSONObject? = nil,
        skillPolicy: JSONObject? = nil,
        toolPolicy: JSONObject? = nil,
        memoryPolicy: JSONObject? = nil,
        gatePolicy: JSONObject? = nil,
        executionPolicy: JSONObject? = nil,
        metadata: JSONObject? = nil
    ) {
        self.label = label
        self.status = status
        self.orchestrator = orchestrator
        self.runtime = runtime
        self.description = description
        self.autonomy = autonomy
        self.backgroundAllowed = backgroundAllowed
        self.requiresHumanApprovalForDestructive = requiresHumanApprovalForDestructive
        self.modelPolicy = modelPolicy
        self.contextPolicy = contextPolicy
        self.skillPolicy = skillPolicy
        self.toolPolicy = toolPolicy
        self.memoryPolicy = memoryPolicy
        self.gatePolicy = gatePolicy
        self.executionPolicy = executionPolicy
        self.metadata = metadata
    }
}

public struct AtlasAiDomainProfileUpdateResponse: Codable, Sendable {
    public let domainProfile: AtlasAiDomainProfile
    public let profileRegistry: AtlasAiPolicyProfileRegistry
}

public struct AtlasAiFlowProfileUpdateResponse: Codable, Sendable {
    public let flowProfile: AtlasAiFlowProfile
    public let profileRegistry: AtlasAiPolicyProfileRegistry
    public let effectivePolicy: JSONObject?
}

// MARK: - Client methods (mirror de atlasAi.ts §1700-1724)

public extension AtlasClient {
    /// GET /ai/policies/profiles
    func getAiPolicyProfiles() async throws -> AtlasAiPolicyProfilesResponse {
        try await get("/ai/policies/profiles")
    }

    /// GET /ai/domains{?domain,flow,maturity}
    func getAiDomainCatalog(
        _ params: AtlasAiDomainCatalogParams = .init()
    ) async throws -> AtlasAiDomainCatalogResponse {
        let q = atlasQueryString([
            ("domain", params.domain.map { .string($0) }),
            ("flow", params.flow.map { .string($0) }),
            ("maturity", params.maturity.map { .string($0) }),
        ])
        return try await get("/ai/domains\(q)")
    }

    /// POST /ai/policies/preview
    func previewAiPolicy(
        _ input: AtlasAiPolicyPreviewInput
    ) async throws -> AtlasAiPolicyPreviewResponse {
        try await post("/ai/policies/preview", body: input)
    }

    /// PATCH /ai/policies/domains/{domainId}
    func updateAiDomainProfile(
        _ domainId: String,
        patch: AtlasAiDomainProfilePatch
    ) async throws -> AtlasAiDomainProfileUpdateResponse {
        let seg = domainId.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? domainId
        return try await self.patch("/ai/policies/domains/\(seg)", body: patch)
    }

    /// PATCH /ai/policies/flows/{flowId}
    func updateAiFlowProfile(
        _ flowId: String,
        patch: AtlasAiFlowProfilePatch
    ) async throws -> AtlasAiFlowProfileUpdateResponse {
        let seg = flowId.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? flowId
        return try await self.patch("/ai/policies/flows/\(seg)", body: patch)
    }
}

// MARK: - Golden checks

/// Decodifica fixtures snake_case realistas e prova o contrato: snake->camel,
/// leitura de bag JSONValue, Int count, Bool e null->nil. Sem framework —
/// roda via `runPoliciesChecks { name, ok in ... }`.
public func runPoliciesChecks(_ check: (String, Bool) -> Void) {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding

    let catalogJSON = """
    {
      "schema_version": 3,
      "status": "ok",
      "source": "registry",
      "filters": { "domain": null, "flow": null, "maturity": "implemented" },
      "summary": {
        "domains": 15, "flows": 42, "orchestrators": 9,
        "implemented_orchestrators": 4, "scaffold_orchestrators": 3,
        "planned_orchestrators": 2, "ready_domains": 11,
        "executable_incomplete_domains": 4
      },
      "domains": [
        {
          "id": "engineering", "label": "Engineering",
          "default_flow": "engineering.build", "orchestrator": "forge_os",
          "orchestrator_maturity": "implemented", "runtime_family": "forge",
          "autonomy_default": "supervised", "background_allowed": true,
          "flow_count": 6,
          "onboarding": {
            "status": "complete", "completed_count": 5, "total_count": 5,
            "completed_phases": ["scope", "design"], "missing_phases": []
          }
        }
      ],
      "flows": [
        {
          "id": "engineering.build", "domain_id": "engineering",
          "label": "Build", "runtime": "forge", "orchestrator": "forge_os",
          "orchestrator_maturity": "implemented", "autonomy": "supervised",
          "background_allowed": true, "destructive_requires_approval": true,
          "executor_preference": "forge"
        }
      ],
      "orchestrators": [
        {
          "id": "forge_os", "class": "obra", "maturity": "implemented",
          "implemented_contract": true,
          "domains": ["engineering"], "flows": ["engineering.build"]
        }
      ],
      "validation": { "valid": true, "errors": [], "warnings": ["draft flow"] },
      "generated_at": "2026-07-12T10:00:00Z"
    }
    """
    if let catalog = try? decoder.decode(AtlasAiDomainCatalogResponse.self, from: Data(catalogJSON.utf8)) {
        check("catalog snake->camel (schemaVersion)", catalog.schemaVersion == 3)
        check("catalog nested snake->camel (orchestratorMaturity)",
              catalog.domains.first?.orchestratorMaturity == "implemented")
        check("catalog Int count (summary.domains)", catalog.summary.domains == 15)
        check("catalog nested Int count (onboarding.completedCount)",
              catalog.domains.first?.onboarding.completedCount == 5)
        check("catalog Bool (backgroundAllowed)", catalog.domains.first?.backgroundAllowed == true)
        check("catalog null->nil optional (filters.domain)", catalog.filters.domain == nil)
        check("catalog reserved-key `class`", catalog.orchestrators.first?.`class` == "obra")
    } else {
        check("catalog decodes", false)
    }

    let profilesJSON = """
    {
      "generated_at": "2026-07-12T10:00:00Z",
      "profile_registry": {
        "schema_version": 2,
        "source": "profiles",
        "domains": [
          {
            "id": "marketing", "label": "Marketing", "status": "active",
            "default_flow": null, "background_allowed": false,
            "metadata": { "owner": "atlas", "priority": 3 }
          }
        ],
        "flows": []
      }
    }
    """
    if let profiles = try? decoder.decode(AtlasAiPolicyProfilesResponse.self, from: Data(profilesJSON.utf8)) {
        let domain = profiles.profileRegistry.domains.first
        check("profiles JSONValue bag reads (metadata.owner)",
              domain?.metadata?["owner"]?.stringValue == "atlas")
        check("profiles null->nil optional (defaultFlow)", domain?.defaultFlow == nil)
    } else {
        check("profiles decodes", false)
    }
}
