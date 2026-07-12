import Foundation

// Cluster de providers/health/status/runtime-settings do Atlas AI, portado de
// lib/api/atlasAi.ts (§462-646, §846-920 + métodos §1696-1732). Superfície admin:
// o operador olha saúde de provider, orçamento de tokens, fila e workers, e ajusta
// runtime settings. Decoder usa `.convertFromSnakeCase` → sem CodingKeys; snake do
// servidor vira camelCase automático. Campo que o servidor pode omitir/nular = Optional.
//
// União aberta (`AtlasAiProvider | string`, status/severity/mode/selection) = String,
// nunca enum — um valor novo do servidor quebraria o decode.
//
// Referência de outro arquivo (não redefinir): AtlasAiExecutionState (cluster Jobs).

// MARK: - Catálogo / policy de modelo

public struct AtlasAiProviderModelCatalogItem: Codable, Sendable {
    public let key: String
    public let alias: String?
    public let model: String?
    public let label: String
    public let tier: String?
    public let description: String?
}

public struct AtlasAiProviderModelPolicy: Codable, Sendable {
    public let provider: String
    public let providerLabel: String?
    public let enabled: Bool?
    public let model: String?
    public let modelLabel: String?
    public let modelTier: String?
    public let modelSource: String?
    public let modelAlias: String?
    public let modelSelection: String?
    public let defaultModelAlias: String?
    public let modelCatalog: [AtlasAiProviderModelCatalogItem]?
    public let allowAuto: Bool
    public let allowManual: Bool
    public let fallbackModel: String?
    public let fallbackModelLabel: String?
    public let premiumModel: String?
    public let premiumModelLabel: String?
}

public struct AtlasAiModelPolicy: Codable, Sendable {
    public let source: String?
    public let updatedAt: String?
    public let defaultTier: String
    public let councilAllowAuto: Bool
    public let providers: [AtlasAiProviderModelPolicy]
}

// MARK: - Health / eventos / fila / workers

public struct AtlasAiProviderHealth: Codable, Sendable {
    public let id: String?
    public let provider: String
    public let providerLabel: String?
    public let enabled: Bool?
    public let model: String?
    public let modelLabel: String?
    public let modelTier: String?
    public let modelSource: String?
    public let modelAlias: String?
    public let modelSelection: String?
    public let defaultModelAlias: String?
    public let modelCatalog: [AtlasAiProviderModelCatalogItem]?
    public let allowAuto: Bool?
    public let allowManual: Bool?
    public let fallbackModel: String?
    public let fallbackModelLabel: String?
    public let premiumModel: String?
    public let premiumModelLabel: String?
    public let status: String
    public let checkedAt: String?
    public let lastSuccessAt: String?
    public let lastFailureAt: String?
    public let totalJobs24h: Int
    public let failedJobs24h: Int
    public let p50LatencyMs: Double?
    public let operationalPainScore: Double
    public let message: String?
    public let metadata: JSONObject?
    public let createdAt: String?
}

public struct AtlasAiWorkerEvent: Codable, Sendable, Identifiable {
    public let id: String
    public let workerId: String
    public let provider: String?
    public let aiJobId: String?
    public let aiJobAttemptId: String?
    public let eventType: String
    public let severity: String
    public let message: String
    public let metadata: JSONObject?
    public let occurredAt: String?
    public let createdAt: String?
}

public struct AtlasAiQueueByProvider: Codable, Sendable {
    public let provider: String?
    public let queued: Int
    public let processing: Int
    public let awaitingUserChoice: Int?
    public let failed: Int
}

public struct AtlasAiQueueStatus: Codable, Sendable {
    public let queued: Int
    public let processing: Int
    public let awaitingUserChoice: Int?
    public let failed: Int
    public let byProvider: [AtlasAiQueueByProvider]?
}

public struct AtlasAiWorkerStatus: Codable, Sendable {
    public let provider: String
    public let status: String
    public let workerId: String?
    public let eventType: String?
    public let severity: String?
    public let message: String?
    public let occurredAt: String?
    public let ageSeconds: Double?
}

// MARK: - Uso / orçamento

public struct AtlasAiProviderUsage: Codable, Sendable {
    public let provider: String
    public let model: String?
    public let traces: Int
    public let failedTraces: Int
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int
    public let estimatedTokens: Int
    public let visibleTokens: Int
    public let costMicrousd: Double
    public let costUsdEstimate: Double
    public let unknownCostCount: Int
    public let lastComputedAt: String?
}

public struct AtlasAiBudgetUsage: Codable, Sendable {
    public let visibleTokens: Int
    public let totalTokens: Int
    public let estimatedTokens: Int
    public let traces: Int
    public let maxVisibleTokens: Int?
    public let warnVisibleTokens: Int?
    public let remainingVisibleTokens: Int?
    public let status: String
}

/// TS `extends AtlasAiBudgetUsage` → achatado: todos os campos de AtlasAiBudgetUsage + provider.
public struct AtlasAiProviderBudget: Codable, Sendable {
    public let visibleTokens: Int
    public let totalTokens: Int
    public let estimatedTokens: Int
    public let traces: Int
    public let maxVisibleTokens: Int?
    public let warnVisibleTokens: Int?
    public let remainingVisibleTokens: Int?
    public let status: String
    public let provider: String
}

public struct AtlasAiBudgetStatus: Codable, Sendable {
    public let available: Bool
    public let enabled: Bool
    public let mode: String
    public let windowHours: Int
    public let totals: AtlasAiBudgetUsage
    public let providers: [AtlasAiProviderBudget]
}

public struct AtlasAiUsageWindow: Codable, Sendable {
    public let available: Bool
    public let windowHours: Int
    public let since: String?
    public let byProvider: [AtlasAiProviderUsage]
    public let byModel: [AtlasAiProviderUsage]?
    public let totals: AtlasAiProviderUsage?
}

// MARK: - Jobs ativos

public struct AtlasAiActiveJob: Codable, Sendable, Identifiable {
    public let id: String
    public let traceId: String?
    public let kind: String?
    public let priority: Int?
    public let provider: String?
    public let model: String?
    public let modelLabel: String?
    public let modelTier: String?
    public let modelSource: String?
    public let atlasDecideExecution: AtlasAiExecutionState?
    public let atlasDecideStage: String?
    public let atlasDecideStrategy: String?
    public let dependencyState: String?
    public let dependencyJobId: String?
    public let dependentJobId: String?
    public let dependencyProvider: String?
    public let dependencyModel: String?
    public let dependencyDeadlineAt: String?
    public let status: String
    public let attempts: Int
    public let workerId: String?
    public let availableAt: String?
    public let startedAt: String?
    public let updatedAt: String?
}

// MARK: - Runtime settings (leitura)

public struct AtlasAiRuntimeBudget: Codable, Sendable {
    public let enabled: Bool
    public let mode: String
    public let windowHours: Int
    public let maxVisibleTokens: Int?
    public let warnVisibleTokens: Int?
    // Record<string, {max/warn_visible_tokens}> — mapa por provider, mantido solto.
    public let providers: JSONObject?
}

public struct AtlasAiRuntimeSettings: Codable, Sendable {
    public let source: String?
    public let updatedAt: String?
    public let defaultProviderSelection: String?
    public let defaultProvider: String
    public let defaultTier: String
    public let councilAllowAuto: Bool
    // Record<string, Partial<AtlasAiProviderModelPolicy>> — mapa solto por provider.
    public let providers: JSONObject?
    public let budget: AtlasAiRuntimeBudget
}

// MARK: - Runtime settings (patch — input Encodable; nil é omitido no encode)

public struct AtlasAiRuntimeSettingsBudgetPatch: Encodable, Sendable {
    public var enabled: Bool?
    public var mode: String?
    public var windowHours: Int?
    public var maxVisibleTokens: Int?
    public var warnVisibleTokens: Int?
    public var providers: JSONObject?

    public init(
        enabled: Bool? = nil,
        mode: String? = nil,
        windowHours: Int? = nil,
        maxVisibleTokens: Int? = nil,
        warnVisibleTokens: Int? = nil,
        providers: JSONObject? = nil
    ) {
        self.enabled = enabled
        self.mode = mode
        self.windowHours = windowHours
        self.maxVisibleTokens = maxVisibleTokens
        self.warnVisibleTokens = warnVisibleTokens
        self.providers = providers
    }
}

public struct AtlasAiRuntimeSettingsPatch: Encodable, Sendable {
    public var defaultProvider: String?
    public var defaultProviderSelection: String?
    public var defaultTier: String?
    public var councilAllowAuto: Bool?
    // Record<string, {model/model_label/model_tier/model_identity/default_model_alias/allow_auto/allow_manual}>.
    public var providers: JSONObject?
    public var budget: AtlasAiRuntimeSettingsBudgetPatch?

    public init(
        defaultProvider: String? = nil,
        defaultProviderSelection: String? = nil,
        defaultTier: String? = nil,
        councilAllowAuto: Bool? = nil,
        providers: JSONObject? = nil,
        budget: AtlasAiRuntimeSettingsBudgetPatch? = nil
    ) {
        self.defaultProvider = defaultProvider
        self.defaultProviderSelection = defaultProviderSelection
        self.defaultTier = defaultTier
        self.councilAllowAuto = councilAllowAuto
        self.providers = providers
        self.budget = budget
    }
}

// MARK: - Envelope de status

public struct AtlasAiProviderChoiceOption: Codable, Sendable {
    public let key: String
    public let provider: String?
    public let label: String
    public let description: String?
}

public struct AtlasAiProviderChoiceCatalog: Codable, Sendable {
    public let schemaVersion: String?
    public let defaultProviderSelection: String?
    public let defaultProvider: String?
    public let defaultProviderOptions: [AtlasAiProviderChoiceOption]?
    public let providers: [AtlasAiProviderModelPolicy]?
}

public struct AiProvidersStatusResponse: Codable, Sendable {
    public let generatedAt: String?
    public let runtimeSettings: AtlasAiRuntimeSettings?
    public let providerChoiceCatalog: AtlasAiProviderChoiceCatalog?
    public let defaultProviderSelection: String?
    public let defaultProvider: String?
    public let defaultModel: AtlasAiProviderModelPolicy?
    public let modelPolicy: AtlasAiModelPolicy?
    public let budget: AtlasAiBudgetStatus?
    public let queue: AtlasAiQueueStatus
    public let workers: [AtlasAiWorkerStatus]?
    public let providers: [AtlasAiProviderHealth]
    public let usage24h: AtlasAiUsageWindow?
    public let activeJobs: [AtlasAiActiveJob]?
    public let recentEvents: [AtlasAiWorkerEvent]
}

public struct AiProvidersCheckResponse: Codable, Sendable {
    public let providers: [AtlasAiProviderHealth]
}

// MARK: - Métodos (mirror de atlasAi.ts §1696-1732)

public extension AtlasClient {
    /// GET /ai/providers/status
    func getAiProvidersStatus() async throws -> AiProvidersStatusResponse {
        try await get("/ai/providers/status")
    }

    /// PATCH /ai/providers/settings
    func updateAiProviderSettings(_ input: AtlasAiRuntimeSettingsPatch) async throws -> AiProvidersStatusResponse {
        try await patch("/ai/providers/settings", body: input)
    }

    /// POST /ai/providers/check (corpo `{}`)
    func checkAiProviders() async throws -> AiProvidersCheckResponse {
        try await post("/ai/providers/check")
    }
}

// MARK: - Golden check

/// Decoda um fixture realista (snake_case, shape do servidor) do tipo principal
/// do cluster e prova: snake→camel, bag JSONValue, Int count, Double score, null→nil.
public func runProvidersChecks(_ check: (String, Bool) -> Void) {
    let json = """
    {
      "generated_at": "2026-07-12T10:00:00Z",
      "default_provider": "claude_cli",
      "queue": { "queued": 3, "processing": 1, "failed": 0 },
      "providers": [
        {
          "id": "ph_1",
          "provider": "claude_cli",
          "status": "online",
          "total_jobs_24h": 42,
          "failed_jobs_24h": 2,
          "p50_latency_ms": 1234.5,
          "operational_pain_score": 0.15,
          "checked_at": "2026-07-12T09:59:00Z",
          "last_failure_at": null,
          "metadata": { "note": "healthy" },
          "created_at": null
        }
      ],
      "recent_events": [
        {
          "id": "ev_1",
          "worker_id": "w_1",
          "event_type": "heartbeat",
          "severity": "info",
          "message": "ok",
          "occurred_at": "2026-07-12T09:58:00Z"
        }
      ]
    }
    """
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = atlasSnakeKeyDecoding
    do {
        let res = try decoder.decode(AiProvidersStatusResponse.self, from: Data(json.utf8))
        let ph = res.providers.first
        check("generated_at → generatedAt", res.generatedAt == "2026-07-12T10:00:00Z")
        check("total_jobs_24h → totalJobs24h (Int)", ph?.totalJobs24h == 42)
        check("queue.queued (Int count)", res.queue.queued == 3)
        check("operational_pain_score (Double)", ph?.operationalPainScore == 0.15)
        check("p50_latency_ms (Double)", ph?.p50LatencyMs == 1234.5)
        check("metadata JSONValue bag", ph?.metadata?["note"]?.stringValue == "healthy")
        check("last_failure_at null → nil", ph?.lastFailureAt == nil)
    } catch {
        check("AiProvidersStatusResponse decodes", false)
    }
}