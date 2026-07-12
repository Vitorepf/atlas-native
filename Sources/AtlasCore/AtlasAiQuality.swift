import Foundation

// Cluster Quality: avaliações de qualidade e ações de remediação portadas de
// lib/api/atlasAi.ts (AtlasAiQualityEvaluation / AtlasAiQualityAction, §420-460;
// listAiQualityActions / runAiQualityAction, §1820-1832). O decoder usa
// `.convertFromSnakeCase` — sem CodingKeys. `AtlasAiQualityStatus` e
// `AtlasAiQualityActionStatus` são uniões abertas no TS (`... | string`), então
// `status`/`action_type`/`provider` ficam `String` — um enum estrito quebraria
// o decode num valor novo do servidor.

/// `AtlasAiQualityEvaluation` (atlasAi.ts). O grafo pesado (dimensions, flags,
/// suggested_actions, metadata) vive como bags `JSONValue`. `actions` é a
/// relação opcional de remediações; `remediation_trace` de cada ação referencia
/// `AtlasAiTrace` (owned pelo loop de conversa).
public struct AtlasAiQualityEvaluation: Codable, Sendable, Identifiable {
    public let id: String
    public let traceId: String?
    public let threadId: String?
    public let sessionId: String?
    public let provider: String?
    public let model: String?
    public let agentSlug: String?
    public let evaluatorVersion: String
    public let score: Double
    public let status: String
    public let dimensions: JSONObject?
    public let flags: [JSONValue]?
    public let suggestedActions: [JSONValue]?
    public let metadata: JSONObject?
    public let actions: [AtlasAiQualityAction]?
    public let createdAt: String
    public let updatedAt: String
}

/// `AtlasAiQualityAction` (atlasAi.ts). `remediation_trace` é a trace da
/// remediação executada, opcional — `AtlasAiTrace` é definido no arquivo do loop
/// de conversa (referência, não redefinir aqui).
public struct AtlasAiQualityAction: Codable, Sendable, Identifiable {
    public let id: String
    public let evaluationId: String?
    public let traceId: String?
    public let remediationTraceId: String?
    public let threadId: String?
    public let sessionId: String?
    public let actionType: String
    public let status: String
    public let priority: Int
    public let reason: String
    public let flags: [JSONValue]?
    public let payload: JSONObject?
    public let result: JSONObject?
    public let errorMessage: String?
    public let dedupeKey: String?
    public let completedAt: String?
    public let remediationTrace: AtlasAiTrace?
    public let createdAt: String
    public let updatedAt: String
}

// MARK: - Envelopes de resposta

public struct AiQualityActionsResponse: Codable, Sendable {
    public let actions: [AtlasAiQualityAction]
}

public struct AiQualityActionResponse: Codable, Sendable {
    public let action: AtlasAiQualityAction
}

// MARK: - Client methods (mirror de atlasAi.ts §1820-1832)

public extension AtlasClient {
    /// GET /ai/quality/actions — `listAiQualityActions`.
    func listAiQualityActions(
        status: String? = nil,
        actionType: String? = nil,
        traceId: String? = nil,
        threadId: String? = nil,
        limit: Int? = nil
    ) async throws -> AiQualityActionsResponse {
        let q = atlasQueryString([
            ("status", status.map { .string($0) }),
            ("action_type", actionType.map { .string($0) }),
            ("trace_id", traceId.map { .string($0) }),
            ("thread_id", threadId.map { .string($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("/ai/quality/actions\(q)")
    }

    /// POST /ai/quality/actions/{id}/run — `runAiQualityAction` (corpo `{}`).
    func runAiQualityAction(_ id: String) async throws -> AiQualityActionResponse {
        let seg = id.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? id
        return try await post("/ai/quality/actions/\(seg)/run")
    }
}

// MARK: - Golden checks

/// Decodifica um fixture realista (snake_case) de `AtlasAiQualityEvaluation` com
/// uma `AtlasAiQualityAction` aninhada e prova: snake->camel, leitura de bag
/// `JSONValue`, `Int` priority, `Double` score e null->nil.
public func runQualityChecks(_ check: (String, Bool) -> Void) {
    let json = """
    {
      "id": "eval_1",
      "trace_id": "trace_9",
      "thread_id": null,
      "session_id": "sess_2",
      "provider": "claude_cli",
      "model": null,
      "agent_slug": "atlas.reviewer",
      "evaluator_version": "v3",
      "score": 0.82,
      "status": "needs_review",
      "dimensions": { "accuracy": 0.9 },
      "flags": [ { "kind": "latency" } ],
      "suggested_actions": [ "retry" ],
      "metadata": { "source": "auto" },
      "actions": [
        {
          "id": "act_1",
          "evaluation_id": "eval_1",
          "trace_id": "trace_9",
          "remediation_trace_id": null,
          "thread_id": null,
          "session_id": "sess_2",
          "action_type": "reroute",
          "status": "queued",
          "priority": 5,
          "reason": "low score",
          "flags": [],
          "payload": { "target": "codex_cli" },
          "result": {},
          "error_message": null,
          "dedupe_key": null,
          "completed_at": null,
          "created_at": "2026-07-01T00:00:00Z",
          "updated_at": "2026-07-01T00:00:00Z"
        }
      ],
      "created_at": "2026-07-01T00:00:00Z",
      "updated_at": "2026-07-01T00:00:00Z"
    }
    """.data(using: .utf8)!

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding

    do {
        let ev = try decoder.decode(AtlasAiQualityEvaluation.self, from: json)
        check("quality: trace_id -> traceId", ev.traceId == "trace_9")
        check("quality: agent_slug -> agentSlug", ev.agentSlug == "atlas.reviewer")
        check("quality: metadata JSONValue reads", ev.metadata?["source"]?.stringValue == "auto")
        check("quality: score is Double", abs(ev.score - 0.82) < 0.0001)
        check("quality: model null -> nil", ev.model == nil)
        check("quality: nested action priority is Int", ev.actions?.first?.priority == 5)
    } catch {
        check("quality: evaluation fixture decodes", false)
    }
}
