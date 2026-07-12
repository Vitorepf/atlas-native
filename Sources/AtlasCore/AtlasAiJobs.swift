import Foundation

// Jobs cluster do Atlas AI, portado de lib/api/atlasAi.ts (AtlasAiJob & cia +
// os endpoints /ai/jobs/*). O decoder do AtlasClient usa `.convertFromSnakeCase`,
// então snake_case do servidor vira camelCase sem CodingKeys. Todo campo que o
// servidor pode omitir ou mandar `null` é Optional — senão o decode quebra.
//
// Uniões abertas (`AtlasAiProvider | string`, status, action) ficam `String`:
// um enum estrito quebraria o decode num valor novo. AtlasAiChoiceAction ->
// String pelo mesmo motivo.

/// `atlas_decide_execution` — estado do Atlas Decide anexado ao job. O TS tem
/// index signature `[key: string]: unknown`, omitida aqui (Decodable ignora
/// chaves JSON desconhecidas por padrão).
public struct AtlasAiExecutionState: Codable, Sendable {
    public let strategy: String?
    public let activationStatus: String?
    public let blockedReason: String?
    public let atlasDecideStage: String?
    public let dependencyState: String?
    public let dependencyJobId: String?
    public let dependentJobId: String?
    public let dependencyProvider: String?
    public let dependencyModel: String?
    public let dependencyTimeoutSeconds: Int?
}

/// Uma opção que o job oferece quando `awaiting_user_choice` (trocar provider,
/// baixar modelo, esperar, cancelar, etc.). `action` é união aberta -> String.
public struct AtlasAiChoiceOption: Codable, Sendable, Identifiable {
    public let id: String
    public let label: String
    public let description: String?
    public let action: String
    public let provider: String?
    public let model: String?
    public let availableAtIso: String?
    public let cliCommand: String?
    public let reason: String?
}

/// Uma tentativa de execução do job (histórico por worker/provider).
public struct AtlasAiJobAttempt: Codable, Sendable, Identifiable {
    public let id: String
    public let aiJobId: String
    public let attemptNumber: Int
    public let workerId: String
    public let provider: String
    public let model: String?
    public let command: [JSONValue]?
    public let commandHash: String?
    public let promptHash: String
    public let responseHash: String?
    public let status: String
    public let exitCode: Int?
    public let durationMs: Int?
    public let outputText: String?
    public let stdoutExcerpt: String?
    public let stderrExcerpt: String?
    public let errorCode: String?
    public let errorMessage: String?
    public let startedAt: String
    public let finishedAt: String?
    public let metadata: JSONObject?
    public let createdAt: String
    public let updatedAt: String
}

/// O job de fila do Atlas AI. `provider`/`status`/`kind` são uniões abertas ->
/// String. Grafo pesado (trace, attempt_history) fica opcional; bags livres
/// (payload, result_json, metadata, context_refs) viram JSONValue.
public struct AtlasAiJob: Codable, Sendable, Identifiable {
    public let id: String
    public let traceId: String?
    public let clientId: String?
    public let kind: String
    public let status: String
    public let priority: Int
    public let agentSlug: String
    public let provider: String?
    public let model: String?
    public let inputText: String
    public let contextRefs: [JSONValue]?
    public let payload: JSONObject?
    public let atlasDecideExecution: AtlasAiExecutionState?
    public let atlasDecideStage: String?
    public let dependencyState: String?
    public let resultText: String?
    public let resultJson: JSONObject?
    public let errorCode: String?
    public let errorMessage: String?
    public let availableAt: String?
    public let reservedAt: String?
    public let startedAt: String?
    public let finishedAt: String?
    public let attempts: Int
    public let maxAttempts: Int
    public let timeoutSeconds: Int
    public let workerId: String?
    public let awaitingUserChoice: Bool?
    public let choiceOptions: [AtlasAiChoiceOption]?
    public let providerChoiceState: String?
    public let providerChoiceErrorCode: String?
    public let providerResetAt: String?
    public let resetHint: String?
    public let metadata: JSONObject?
    public let trace: AtlasAiTrace?
    public let attemptHistory: [AtlasAiJobAttempt]?
    public let createdAt: String
    public let updatedAt: String
}

// MARK: - Envelopes de resposta

public struct AiJobsResponse: Codable, Sendable { public let jobs: [AtlasAiJob] }
public struct AiJobResponse: Codable, Sendable { public let job: AtlasAiJob }

// MARK: - Client methods (mirror de listAiJobs/getAiJob/retryAiJob/
// cancelAiJob/resumeAiJobChoice — atlasAi.ts §1662-1694)

public extension AtlasClient {
    func listAiJobs(
        status: String? = nil, provider: String? = nil, limit: Int? = nil
    ) async throws -> AiJobsResponse {
        let q = atlasQueryString([
            ("status", status.map { .string($0) }),
            ("provider", provider.map { .string($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("/ai/jobs\(q)")
    }

    func getAiJob(_ id: String) async throws -> AiJobResponse {
        try await get("/ai/jobs/\(jobPathSeg(id))")
    }

    func retryAiJob(_ id: String) async throws -> AiJobResponse {
        try await post("/ai/jobs/\(jobPathSeg(id))/retry")
    }

    func cancelAiJob(_ id: String) async throws -> AiJobResponse {
        try await post("/ai/jobs/\(jobPathSeg(id))/cancel")
    }

    func resumeAiJobChoice(_ jobId: String, optionId: String) async throws -> AiJobResponse {
        try await post(
            "/ai/jobs/\(jobPathSeg(jobId))/resume-choice",
            body: ResumeChoiceInput(optionId: optionId)
        )
    }
}

/// POST body de `resumeAiJobChoice` — o encoder faz `.convertToSnakeCase`
/// (optionId -> option_id), casando o `{ option_id }` do .ts.
private struct ResumeChoiceInput: Encodable {
    let optionId: String
}

/// `encodeURIComponent` para segmento de path (encodeURIComponentAllowed já
/// definido no módulo). File-private: não colide com helpers de outros clusters.
private func jobPathSeg(_ s: String) -> String {
    s.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? s
}

// MARK: - Golden checks

/// Decoda um fixture realista (snake_case, shape do servidor) da resposta
/// principal do cluster e prova: snake->camel, bag JSONValue, contador Int,
/// null->nil, união aberta (action) como String, struct aninhada.
public func runJobsChecks(_ check: (String, Bool) -> Void) {
    let json = """
    {
      "jobs": [
        {
          "id": "job_1",
          "trace_id": null,
          "client_id": "cli_9",
          "kind": "interaction",
          "status": "awaiting_user_choice",
          "priority": 5,
          "agent_slug": "atlas.router",
          "provider": "claude_cli",
          "model": null,
          "input_text": "resume this",
          "context_refs": [],
          "payload": {"topic": "jobs"},
          "atlas_decide_execution": {
            "strategy": "sequential",
            "dependency_timeout_seconds": 30
          },
          "result_text": null,
          "result_json": {},
          "error_code": null,
          "error_message": null,
          "available_at": null,
          "reserved_at": null,
          "started_at": null,
          "finished_at": null,
          "attempts": 2,
          "max_attempts": 3,
          "timeout_seconds": 120,
          "worker_id": null,
          "awaiting_user_choice": true,
          "choice_options": [
            {"id": "opt_switch", "label": "Switch provider", "action": "switch_provider"}
          ],
          "metadata": {"source": "cli"},
          "attempt_history": [
            {
              "id": "att_1",
              "ai_job_id": "job_1",
              "attempt_number": 1,
              "worker_id": "worker_a",
              "provider": "claude_cli",
              "model": "claude-opus",
              "command": ["claude", "run"],
              "command_hash": null,
              "prompt_hash": "abc123",
              "response_hash": null,
              "status": "failed",
              "exit_code": 1,
              "duration_ms": 8421,
              "output_text": null,
              "stdout_excerpt": null,
              "stderr_excerpt": "boom",
              "error_code": "provider_error",
              "error_message": "provider failed",
              "started_at": "2026-07-12T10:00:00Z",
              "finished_at": "2026-07-12T10:00:08Z",
              "metadata": {},
              "created_at": "2026-07-12T10:00:00Z",
              "updated_at": "2026-07-12T10:00:08Z"
            }
          ],
          "created_at": "2026-07-12T09:59:00Z",
          "updated_at": "2026-07-12T10:00:08Z"
        }
      ]
    }
    """
    let dec = JSONDecoder()
    dec.keyDecodingStrategy = atlasSnakeKeyDecoding
    do {
        let resp = try dec.decode(AiJobsResponse.self, from: Data(json.utf8))
        let job = resp.jobs[0]
        check("jobs snake->camel: agentSlug", job.agentSlug == "atlas.router")
        check("jobs snake->camel: inputText", job.inputText == "resume this")
        check("jobs Int count: attempts", job.attempts == 2)
        check("jobs Int: timeoutSeconds", job.timeoutSeconds == 120)
        check("jobs null->nil: traceId", job.traceId == nil)
        check("jobs metadata JSONValue", job.metadata?["source"]?.stringValue == "cli")
        check("jobs open-union action String", job.choiceOptions?.first?.action == "switch_provider")
        check("jobs nested attempt durationMs Int", job.attemptHistory?.first?.durationMs == 8421)
        check("jobs nested execution state", job.atlasDecideExecution?.dependencyTimeoutSeconds == 30)
    } catch {
        check("jobs decodes AiJobsResponse", false)
    }
}
