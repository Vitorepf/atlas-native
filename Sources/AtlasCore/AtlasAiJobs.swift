import Foundation

// Jobs cluster do Atlas AI, portado de lib/api/atlasAi.ts (AtlasAiJob & cia +
// os endpoints /ai/jobs/*). O decoder do AtlasClient usa `.convertFromSnakeCase`,
// então snake_case do servidor vira camelCase sem CodingKeys. Todo campo que o
// servidor pode omitir ou mandar `null` é Optional — senão o decode quebra.
//
// Uniões abertas (`AtlasAiProvider | string`, status, action) ficam `String`:
// um enum estrito quebraria o decode num valor novo. AtlasAiChoiceAction ->
// String pelo mesmo motivo.
// Client: AtlasClient+AiJobs.swift

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
