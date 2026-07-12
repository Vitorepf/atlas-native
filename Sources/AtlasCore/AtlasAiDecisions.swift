import Foundation

// Cluster "Decisions" portado de lib/api/atlasAi.ts (§176-239, métodos §1525-1545).
// O router escolhe provider; o AtlasDecision é o registro auditado da escolha; o
// receipt é o preview/decision_receipt não persistido. Uniões abertas de provider
// e decision_mode viram String (um enum estrito quebraria o decode num valor novo).
// Todo Record<string,unknown> e campo que o servidor pode omitir/nullar é opcional.

/// `router_decision` cru: a saída do roteador antes de virar AtlasDecision auditado.
public struct AtlasAiRouterDecision: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let mode: String
    public let selectedProvider: String?
    public let fallbackProvider: String?
    public let signals: JSONObject?
    public let reason: String
    public let wasOverridden: Bool
    public let createdAt: String?
    public let updatedAt: String?
}

/// O receipt do preview (`previewAiDecision`) — decision_receipt não persistido.
/// Tudo opcional: o servidor monta o receipt por partes conforme a rota resolve.
public struct AtlasAiDecisionReceipt: Codable, Sendable, Equatable {
    public let decisionId: String?
    public let traceId: String?
    public let schemaVersion: Int?
    public let decisionMode: String?
    public let candidateProvider: String?
    public let selectedProvider: String?
    public let selectedModel: String?
    public let fallbackProvider: String?
    public let fallbackReason: String?
    public let operatorRequestedProvider: String?
    public let requestedProvider: String?
    public let wasOverridden: Bool?
    public let reason: String?
    public let signals: JSONObject?
    public let candidates: [JSONValue]?
    public let constraints: JSONObject?
    public let metricsSnapshot: JSONObject?
    public let taskProfile: JSONObject?
    public let contextStrategy: String?
    public let executionStrategy: String?
    public let executionGraph: JSONObject?
}

/// O AtlasDecision persistido/auditado (`listAiDecisions`). id não-nulo → Identifiable.
public struct AtlasAiDecision: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let traceId: String?
    public let routerDecisionId: String?
    public let policyVersion: String
    public let decisionMode: String
    public let routeMode: String?
    public let taskType: String?
    public let riskLevel: String?
    public let contextStrategy: String?
    public let executionStrategy: String?
    public let selectedProvider: String?
    public let selectedModel: String?
    public let fallbackProvider: String?
    public let operatorRequestedProvider: String?
    public let requestedProvider: String?
    public let wasOverridden: Bool
    public let confidenceScore: Double?
    public let signals: JSONObject?
    public let candidates: [JSONValue]?
    public let constraints: JSONObject?
    public let metricsSnapshot: JSONObject?
    public let taskProfile: JSONObject?
    public let executionGraph: JSONObject?
    public let reason: String
    public let createdAt: String?
    public let updatedAt: String?
}

// MARK: - Envelopes de resposta

public struct AiDecisionsResponse: Codable, Sendable {
    public let decisions: [AtlasAiDecision]
}

public struct AiDecisionPreviewResponse: Codable, Sendable {
    public let decision: AtlasAiDecisionReceipt
}

// MARK: - Input de preview (POST /ai/decisions/preview; encoder faz convertToSnakeCase)

public struct PreviewAiDecisionInput: Encodable, Sendable {
    public var inputText: String
    public var provider: String?
    public var model: String?
    public var sourceType: String?
    public var agentSlug: String?
    public var mode: String?
    public var payload: JSONObject?

    public init(
        inputText: String,
        provider: String? = nil,
        model: String? = nil,
        sourceType: String? = nil,
        agentSlug: String? = nil,
        mode: String? = nil,
        payload: JSONObject? = nil
    ) {
        self.inputText = inputText
        self.provider = provider
        self.model = model
        self.sourceType = sourceType
        self.agentSlug = agentSlug
        self.mode = mode
        self.payload = payload
    }
}

// MARK: - Client methods (mirror de listAiDecisions / previewAiDecision)

public extension AtlasClient {
    /// GET /ai/decisions — filtros opcionais viram query (bool/limit tratados pelo helper).
    func listAiDecisions(
        traceId: String? = nil,
        provider: String? = nil,
        decisionMode: String? = nil,
        taskType: String? = nil,
        limit: Int? = nil
    ) async throws -> AiDecisionsResponse {
        let q = atlasQueryString([
            ("trace_id", traceId.map { .string($0) }),
            ("provider", provider.map { .string($0) }),
            ("decision_mode", decisionMode.map { .string($0) }),
            ("task_type", taskType.map { .string($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("/ai/decisions\(q)")
    }

    /// POST /ai/decisions/preview — resolve a rota sem persistir; retorna o receipt.
    func previewAiDecision(_ input: PreviewAiDecisionInput) async throws -> AiDecisionPreviewResponse {
        try await post("/ai/decisions/preview", body: input)
    }
}

// MARK: - Golden check (fixture real, snake_case, decoder .convertFromSnakeCase)

public func runDecisionsChecks(_ check: (String, Bool) -> Void) {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding

    let decisionsJSON = """
    {
      "decisions": [
        {
          "id": "dec_1",
          "trace_id": "trace_abc",
          "router_decision_id": "rd_9",
          "policy_version": "v3",
          "decision_mode": "atlas_decide",
          "route_mode": "single",
          "task_type": "code",
          "risk_level": "low",
          "context_strategy": "semantic",
          "execution_strategy": "direct",
          "selected_provider": "claude_cli",
          "selected_model": "claude-opus",
          "fallback_provider": null,
          "operator_requested_provider": "auto",
          "requested_provider": null,
          "was_overridden": false,
          "confidence_score": 0.82,
          "signals": { "complexity": "high", "token_estimate": 1200 },
          "candidates": [ { "provider": "claude_cli", "score": 0.9 } ],
          "constraints": { "max_latency_ms": 3000 },
          "metrics_snapshot": { "p50_latency_ms": 420.5 },
          "task_profile": { "kind": "engineering" },
          "execution_graph": { "nodes": 3 },
          "reason": "best fit",
          "created_at": "2026-07-12T00:00:00Z",
          "updated_at": null
        }
      ]
    }
    """

    do {
        let resp = try decoder.decode(AiDecisionsResponse.self, from: Data(decisionsJSON.utf8))
        let d = resp.decisions[0]
        check("decisions: snake->camel (trace_id -> traceId)", d.traceId == "trace_abc")
        check("decisions: router_decision_id -> routerDecisionId", d.routerDecisionId == "rd_9")
        check("decisions: confidence_score -> Double", d.confidenceScore == 0.82)
        check("decisions: JSONValue signals bag reads", d.signals?["complexity"]?.stringValue == "high")
        check("decisions: null updated_at -> nil", d.updatedAt == nil)
    } catch {
        check("decisions: AiDecisionsResponse decodes", false)
    }

    let receiptJSON = """
    {
      "decision": {
        "decision_id": "dec_1",
        "schema_version": 2,
        "decision_mode": "manual_override",
        "candidate_provider": "codex_cli",
        "fallback_reason": null,
        "was_overridden": true,
        "candidates": [ { "provider": "codex_cli" } ],
        "metrics_snapshot": { "cost_usd_estimate": 0.0123 }
      }
    }
    """

    do {
        let resp = try decoder.decode(AiDecisionPreviewResponse.self, from: Data(receiptJSON.utf8))
        let r = resp.decision
        check("receipt: schema_version -> Int", r.schemaVersion == 2)
        check("receipt: null fallback_reason -> nil", r.fallbackReason == nil)
    } catch {
        check("receipt: AiDecisionPreviewResponse decodes", false)
    }
}
