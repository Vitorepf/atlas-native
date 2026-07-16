import Foundation

// Tipos de qualidade pinados por `AtlasAiTrace` (qualityEvaluation /
// qualityActions). As rotas admin list/run foram podadas em F0.3 — 0
// consumidores de produto. `status`/`action_type`/`provider` ficam String
// (uniões abertas no wire).

/// Avaliação de qualidade embutida no trace. Bags pesados vivem como `JSONValue`.
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

/// Ação de remediação ligada à avaliação. `remediationTrace` referencia
/// `AtlasAiTrace` do loop de conversa.
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
