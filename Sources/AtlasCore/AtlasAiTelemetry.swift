import Foundation

// Telemetry / observability / cost-rates / outcomes — a admin surface do Atlas
// AI portada de lib/api/atlasAi.ts (§922-1153 tipos, §1734-1818 métodos). Não é
// o loop de conversa (isso vive em AtlasAiModels.swift); é o que alimenta os
// scorecards, health e custo. Decoder usa `.convertFromSnakeCase`, então tudo é
// camelCase sem CodingKeys. Uniões abertas (provider/status/severity/runtime/
// surface) ficam String — um enum estrito quebraria o decode num valor novo.
// Médias/rates/scores/latência/custo são Double? (JSONDecoder joga a exceção ao
// decodificar fracionário em Int); counts/ids/posições são Int?.

// MARK: - Bloco compartilhado

/// `{ since, until }` — a mesma janela aparece em observability, scorecard e
/// health. Optionals por segurança (o servidor pode omitir/nullar).
public struct AtlasAiTelemetryWindow: Codable, Sendable {
    public let since: String?
    public let until: String?
}

// MARK: - AiObservabilityResponse

public struct AtlasAiObservabilityThreads: Codable, Sendable {
    public let active: Int?
    public let atlasCli: Int?
}

public struct AtlasAiObservabilityTraces: Codable, Sendable {
    public let total: Int?
    public let byStatus: [String: Int]?
    public let byProvider: [String: Int]?
}

public struct AtlasAiObservabilityJobs: Codable, Sendable {
    public let queued: Int?
    public let processing: Int?
    public let failed24h: Int?
}

public struct AtlasAiObservabilityQualityItem: Codable, Sendable, Identifiable {
    public let id: String
    public let traceId: String?
    public let threadId: String?
    public let provider: String?
    public let score: Double?
    public let status: String?
    public let flags: [String]?
    public let createdAt: String?
}

public struct AtlasAiObservabilityQuality: Codable, Sendable {
    public let available: Bool?
    public let total: Int?
    public let averageScore: Double?
    public let byStatus: [String: Int]?
    public let recentNeedsReview: [AtlasAiObservabilityQualityItem]?
}

public struct AtlasAiObservabilityActionItem: Codable, Sendable, Identifiable {
    public let id: String
    public let traceId: String?
    public let remediationTraceId: String?
    public let actionType: String?
    public let status: String?
    public let priority: Int?
    public let reason: String?
    public let createdAt: String?
}

public struct AtlasAiObservabilityActions: Codable, Sendable {
    public let available: Bool?
    public let byStatus: [String: Int]?
    public let open: Int?
    public let recent: [AtlasAiObservabilityActionItem]?
}

public struct AiObservabilityResponse: Codable, Sendable {
    public let window: AtlasAiTelemetryWindow?
    public let threads: AtlasAiObservabilityThreads?
    public let traces: AtlasAiObservabilityTraces?
    public let jobs: AtlasAiObservabilityJobs?
    public let quality: AtlasAiObservabilityQuality?
    public let metrics: AtlasAiTelemetryScorecard?
    public let metricsHealth: AtlasAiTelemetryHealth?
    public let actions: AtlasAiObservabilityActions?
}

// MARK: - AtlasAiTelemetryScorecard

public struct AtlasAiTelemetryScorecardTotals: Codable, Sendable {
    public let traces: Int?
    public let finalQualityAvg: Double?
    public let finalEfficiencyAvg: Double?
    public let contextEfficiencyAvg: Double?
    public let totalLatencyAvgMs: Double?
    public let appVisibleAvgMs: Double?
    public let costMicrousdSum: Double?
    public let unknownCostCount: Int?
    public let estimatedCostCount: Int?
    public let actualCostCount: Int?
    public let operationalEstimateCostCount: Int?
    public let firstPassSuccessRate: Double?
    public let neededRemediationRate: Double?
    public let backgroundedDuringRunRate: Double?
    public let recoveredFromPendingCount: Int?
    public let reaskDetectedCount: Int?
    public let atlasDecideTraceCount: Int?
    public let atlasDecideMultiStageCount: Int?
    public let atlasDecideDegradedCount: Int?
}

public struct AtlasAiTelemetryScorecardBucket: Codable, Sendable {
    public let bucket: String?
    public let traces: Int?
    public let qualityAvg: Double?
    public let efficiencyAvg: Double?
    public let latencyAvgMs: Double?
    public let costMicrousdSum: Double?
    public let unknownCostCount: Int?
    public let estimatedCostCount: Int?
    public let firstPassSuccessRate: Double?
    public let neededRemediationRate: Double?
}

public struct AtlasAiTelemetryAtlasBucket: Codable, Sendable {
    public let bucket: String?
    public let traces: Int?
    public let qualityAvg: Double?
    public let efficiencyAvg: Double?
    public let latencyAvgMs: Double?
    public let costMicrousdSum: Double?
    public let multiStageRate: Double?
    public let degradedRate: Double?
    public let providersUsed: [String]?
}

public struct AtlasAiTelemetryScorecardAtlasDecide: Codable, Sendable {
    public let available: Bool?
    public let traces: Int?
    public let multiStageCount: Int?
    public let multiStageRate: Double?
    public let degradedCount: Int?
    public let degradedRate: Double?
    public let byExecutionStrategy: [AtlasAiTelemetryAtlasBucket]?
    public let byContextStrategy: [AtlasAiTelemetryAtlasBucket]?
    public let bySelectedProvider: [AtlasAiTelemetryAtlasBucket]?
    public let byScoutProvider: [AtlasAiTelemetryAtlasBucket]?
}

public struct AtlasAiTelemetryScorecard: Codable, Sendable {
    public let available: Bool?
    public let window: AtlasAiTelemetryWindow?
    public let totals: AtlasAiTelemetryScorecardTotals?
    public let bySurface: [AtlasAiTelemetryScorecardBucket]?
    public let byProvider: [AtlasAiTelemetryScorecardBucket]?
    public let byTaskType: [AtlasAiTelemetryScorecardBucket]?
    public let byAtlasDecideExecutionStrategy: [AtlasAiTelemetryAtlasBucket]?
    public let byAtlasDecideContextStrategy: [AtlasAiTelemetryAtlasBucket]?
    public let atlasDecide: AtlasAiTelemetryScorecardAtlasDecide?
    public let risks: [String: Int]?
    public let recentLowScore: [JSONObject]?
}

// MARK: - AtlasAiTelemetryHealth

public struct AtlasAiTelemetryHealthIssue: Codable, Sendable {
    public let key: String?
    public let severity: String?
    public let value: JSONValue?
    public let threshold: JSONValue?
    public let summary: String?
}

public struct AtlasAiMissingCostRate: Codable, Sendable {
    public let provider: String?
    public let model: String?
    public let reason: String?
    public let canImportRate: Bool?
    public let traces: Int?
    public let latestComputedAt: String?
    public let rateTemplate: JSONObject?
}

/// `evidence` no TS tem `missing_cost_rates?` + index signature `[key]: unknown`.
/// Index signature é omitida (Decodable ignora chaves JSON desconhecidas).
public struct AtlasAiTelemetryHealthEvidence: Codable, Sendable {
    public let missingCostRates: [AtlasAiMissingCostRate]?
}

public struct AtlasAiTelemetryHealth: Codable, Sendable {
    public let available: Bool?
    public let status: String?
    public let healthScore: Double?
    public let window: AtlasAiTelemetryWindow?
    public let thresholds: JSONObject?
    public let issues: [AtlasAiTelemetryHealthIssue]?
    public let evidence: AtlasAiTelemetryHealthEvidence?
    public let actions: [String]?
    public let scorecard: AtlasAiTelemetryScorecard?
}

// MARK: - Telemetry event input (Encodable) + batch response

/// Corpo de `postAiTelemetryEvents`. camelCase → o encoder faz
/// `.convertToSnakeCase` (todos os campos round-trip limpo).
public struct AtlasAiTelemetryEventInput: Encodable, Sendable {
    public var surface: String
    public var eventName: String
    public var eventKey: String?
    public var correlationId: String?
    public var traceId: String?
    public var threadId: String?
    public var sessionId: String?
    public var aiJobId: String?
    public var aiJobAttemptId: String?
    public var clientId: String?
    public var runtime: String?
    public var appVersion: String?
    public var cliVersion: String?
    public var provider: String?
    public var model: String?
    public var agentSlug: String?
    public var eventPhase: String?
    public var occurredAtClient: String?
    public var durationMs: Int?
    public var numericValue: Double?
    public var unit: String?
    public var metadata: JSONObject?
    public var privacy: JSONObject?
    public var schemaVersion: Int?

    public init(
        surface: String,
        eventName: String,
        eventKey: String? = nil,
        correlationId: String? = nil,
        traceId: String? = nil,
        threadId: String? = nil,
        sessionId: String? = nil,
        aiJobId: String? = nil,
        aiJobAttemptId: String? = nil,
        clientId: String? = nil,
        runtime: String? = nil,
        appVersion: String? = nil,
        cliVersion: String? = nil,
        provider: String? = nil,
        model: String? = nil,
        agentSlug: String? = nil,
        eventPhase: String? = nil,
        occurredAtClient: String? = nil,
        durationMs: Int? = nil,
        numericValue: Double? = nil,
        unit: String? = nil,
        metadata: JSONObject? = nil,
        privacy: JSONObject? = nil,
        schemaVersion: Int? = nil
    ) {
        self.surface = surface
        self.eventName = eventName
        self.eventKey = eventKey
        self.correlationId = correlationId
        self.traceId = traceId
        self.threadId = threadId
        self.sessionId = sessionId
        self.aiJobId = aiJobId
        self.aiJobAttemptId = aiJobAttemptId
        self.clientId = clientId
        self.runtime = runtime
        self.appVersion = appVersion
        self.cliVersion = cliVersion
        self.provider = provider
        self.model = model
        self.agentSlug = agentSlug
        self.eventPhase = eventPhase
        self.occurredAtClient = occurredAtClient
        self.durationMs = durationMs
        self.numericValue = numericValue
        self.unit = unit
        self.metadata = metadata
        self.privacy = privacy
        self.schemaVersion = schemaVersion
    }
}

public struct AtlasAiTelemetryBatchEvent: Codable, Sendable, Identifiable {
    public let id: String
    public let eventKey: String?
    public let duplicate: Bool?
}

public struct AtlasAiTelemetryBatchError: Codable, Sendable {
    public let index: Int?
    public let message: String?
}

public struct AtlasAiTelemetryBatchResponse: Codable, Sendable {
    public let accepted: Int?
    public let duplicates: Int?
    public let rejected: Int?
    public let events: [AtlasAiTelemetryBatchEvent]?
    public let errors: [AtlasAiTelemetryBatchError]?
}

// MARK: - Cost rates + outcomes

public struct AtlasAiProviderCostRate: Codable, Sendable, Identifiable {
    public let id: String
    public let provider: String?
    public let model: String?
    public let inputMicrousdPer1k: Double?
    public let outputMicrousdPer1k: Double?
    public let currency: String?
    public let effectiveFrom: String?
    public let effectiveUntil: String?
    public let metadata: JSONObject?
    public let createdAt: String?
}

public struct AtlasAiOutcomeLink: Codable, Sendable, Identifiable {
    public let id: String
    public let traceId: String?
    public let threadId: String?
    public let sessionId: String?
    public let outcomeType: String?
    public let targetType: String?
    public let targetId: String?
    public let valueScore: Double?
    public let confidence: Double?
    public let source: String?
    public let occurredAt: String?
    public let metadata: JSONObject?
    public let createdAt: String?
}

// MARK: - Response envelopes

public struct AtlasAiTelemetryScorecardResponse: Codable, Sendable {
    public let scorecard: AtlasAiTelemetryScorecard?
    public let health: AtlasAiTelemetryHealth?
    public let recomputed: Int?
}

public struct AiTelemetryHealthInsight: Codable, Sendable {
    public let emitted: Bool?
    public let itemId: String?
    public let reason: String?
}

public struct AiTelemetryHealthResponse: Codable, Sendable {
    public let health: AtlasAiTelemetryHealth?
    public let insight: AiTelemetryHealthInsight?
    public let recomputed: Int?
}

public struct AiProviderCostRatesResponse: Codable, Sendable {
    public let available: Bool?
    public let rates: [AtlasAiProviderCostRate]?
}

public struct AiMissingCostRatesResponse: Codable, Sendable {
    public let available: Bool?
    public let missingRates: [AtlasAiMissingCostRate]?
}

public struct AiProviderCostRateResponse: Codable, Sendable {
    public let rate: AtlasAiProviderCostRate?
}

public struct AiOutcomeResponse: Codable, Sendable {
    public let outcome: AtlasAiOutcomeLink?
}

public struct AiOutcomesResponse: Codable, Sendable {
    public let available: Bool?
    public let outcomes: [AtlasAiOutcomeLink]?
}

// MARK: - Input de `recordAiOutcome` (round-trip limpo → struct tipada)

public struct RecordAiOutcomeInput: Encodable, Sendable {
    public var outcomeType: String
    public var traceId: String?
    public var threadId: String?
    public var sessionId: String?
    public var targetType: String?
    public var targetId: String?
    public var valueScore: Double?
    public var confidence: Double?
    public var source: String?
    public var occurredAt: String?
    public var metadata: JSONObject?

    public init(
        outcomeType: String,
        traceId: String? = nil,
        threadId: String? = nil,
        sessionId: String? = nil,
        targetType: String? = nil,
        targetId: String? = nil,
        valueScore: Double? = nil,
        confidence: Double? = nil,
        source: String? = nil,
        occurredAt: String? = nil,
        metadata: JSONObject? = nil
    ) {
        self.outcomeType = outcomeType
        self.traceId = traceId
        self.threadId = threadId
        self.sessionId = sessionId
        self.targetType = targetType
        self.targetId = targetId
        self.valueScore = valueScore
        self.confidence = confidence
        self.source = source
        self.occurredAt = occurredAt
        self.metadata = metadata
    }
}

/// Wrapper de corpo para `postAiTelemetryEvents` → `{ events: [...] }`.
private struct AtlasAiTelemetryEventsBody: Encodable {
    let events: [AtlasAiTelemetryEventInput]
}

// MARK: - Client methods (mirror de atlasAi.ts §1734-1818)

public extension AtlasClient {
    /// GET /ai/observability
    func getAiObservability(hours: Int? = nil) async throws -> AiObservabilityResponse {
        let q = atlasQueryString([("hours", hours.map { .int($0) })])
        return try await get("/ai/observability\(q)")
    }

    /// POST /ai/telemetry/events — corpo `{ events }`. (O branch mobile
    /// `/v1/mobile/telemetry/events` do .ts é device concern; aqui só o
    /// caminho /ai.)
    func postAiTelemetryEvents(_ events: [AtlasAiTelemetryEventInput]) async throws -> AtlasAiTelemetryBatchResponse {
        try await post("/ai/telemetry/events", body: AtlasAiTelemetryEventsBody(events: events))
    }

    /// GET /ai/telemetry/scorecard
    func getAiTelemetryScorecard(hours: Int? = nil, recompute: Bool? = nil) async throws -> AtlasAiTelemetryScorecardResponse {
        let q = atlasQueryString([
            ("hours", hours.map { .int($0) }),
            ("recompute", recompute.map { .bool($0) }),
        ])
        return try await get("/ai/telemetry/scorecard\(q)")
    }

    /// GET /ai/telemetry/health
    func getAiTelemetryHealth(hours: Int? = nil, recompute: Bool? = nil, emit: Bool? = nil) async throws -> AiTelemetryHealthResponse {
        let q = atlasQueryString([
            ("hours", hours.map { .int($0) }),
            ("recompute", recompute.map { .bool($0) }),
            ("emit", emit.map { .bool($0) }),
        ])
        return try await get("/ai/telemetry/health\(q)")
    }

    /// GET /ai/telemetry/cost-rates
    func listAiProviderCostRates(provider: String? = nil, model: String? = nil, active: Bool? = nil, limit: Int? = nil) async throws -> AiProviderCostRatesResponse {
        let q = atlasQueryString([
            ("provider", provider.map { .string($0) }),
            ("model", model.map { .string($0) }),
            ("active", active.map { .bool($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("/ai/telemetry/cost-rates\(q)")
    }

    /// GET /ai/telemetry/cost-rates/missing
    func listMissingAiProviderCostRates(hours: Int? = nil, limit: Int? = nil) async throws -> AiMissingCostRatesResponse {
        let q = atlasQueryString([
            ("hours", hours.map { .int($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("/ai/telemetry/cost-rates/missing\(q)")
    }

    /// POST /ai/telemetry/cost-rates. ponytail: corpo é `[String: JSONValue]`
    /// com as chaves exatas do servidor, não uma struct tipada —
    /// `input_microusd_per_1k` NÃO sobrevive a `.convertToSnakeCase` (Swift
    /// emitiria `input_microusd_per1k`, perdendo o `_` antes do dígito). As
    /// chaves aqui não têm maiúscula, então o encoder as deixa intactas.
    func upsertAiProviderCostRate(
        provider: String,
        model: String,
        inputMicrousdPer1k: Double,
        outputMicrousdPer1k: Double,
        currency: String? = nil,
        effectiveFrom: String? = nil,
        effectiveUntil: String? = nil,
        metadata: JSONObject? = nil
    ) async throws -> AiProviderCostRateResponse {
        var body: [String: JSONValue] = [
            "provider": .string(provider),
            "model": .string(model),
            "input_microusd_per_1k": .number(inputMicrousdPer1k),
            "output_microusd_per_1k": .number(outputMicrousdPer1k),
        ]
        if let currency { body["currency"] = .string(currency) }
        if let effectiveFrom { body["effective_from"] = .string(effectiveFrom) }
        if let effectiveUntil { body["effective_until"] = .string(effectiveUntil) }
        if let metadata { body["metadata"] = .object(metadata.values) }
        return try await post("/ai/telemetry/cost-rates", body: body)
    }

    /// POST /ai/telemetry/outcomes
    func recordAiOutcome(_ input: RecordAiOutcomeInput) async throws -> AiOutcomeResponse {
        try await post("/ai/telemetry/outcomes", body: input)
    }

    /// GET /ai/telemetry/outcomes
    func listAiOutcomes(traceId: String? = nil, threadId: String? = nil, outcomeType: String? = nil, limit: Int? = nil) async throws -> AiOutcomesResponse {
        let q = atlasQueryString([
            ("trace_id", traceId.map { .string($0) }),
            ("thread_id", threadId.map { .string($0) }),
            ("outcome_type", outcomeType.map { .string($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("/ai/telemetry/outcomes\(q)")
    }
}

// MARK: - Golden checks

/// Decodifica um fixture real (snake_case) do scorecard e prova os invariantes
/// que quebram fácil: snake→camel, count Int, rate Double, bag JSONValue e
/// null→nil. Chame com um `check` que faça assert/print.
public func runTelemetryChecks(_ check: (String, Bool) -> Void) {
    let json = """
    {
      "scorecard": {
        "available": true,
        "window": { "since": "2026-07-01T00:00:00Z", "until": "2026-07-12T00:00:00Z" },
        "totals": {
          "traces": 128,
          "final_quality_avg": 0.87,
          "final_efficiency_avg": null,
          "total_latency_avg_ms": 2450.5,
          "cost_microusd_sum": 730000,
          "unknown_cost_count": 3,
          "first_pass_success_rate": 0.92,
          "needed_remediation_rate": null
        },
        "by_provider": [
          {
            "bucket": "claude_cli",
            "traces": 40,
            "quality_avg": 0.9,
            "efficiency_avg": null,
            "latency_avg_ms": 1900.0,
            "cost_microusd_sum": 500000,
            "first_pass_success_rate": 0.95,
            "needed_remediation_rate": null
          }
        ],
        "risks": { "low_score": 4 },
        "recent_low_score": [ { "trace_id": "trc_1", "score": 0.31 } ]
      },
      "health": {
        "available": true,
        "status": "watch",
        "health_score": 0.78,
        "issues": [
          { "key": "latency", "severity": "warning", "value": 3200, "threshold": 3000, "summary": "Latency above target" }
        ],
        "actions": ["Investigate latency"]
      },
      "recomputed": null
    }
    """

    let dec = JSONDecoder()
    dec.keyDecodingStrategy = atlasSnakeKeyDecoding
    do {
        let resp = try dec.decode(AtlasAiTelemetryScorecardResponse.self, from: Data(json.utf8))
        check("snake→camel maps (final_quality_avg→finalQualityAvg)", resp.scorecard?.totals?.finalQualityAvg == 0.87)
        check("Int count decodes (totals.traces)", resp.scorecard?.totals?.traces == 128)
        check("Double rate decodes (first_pass_success_rate)", resp.scorecard?.totals?.firstPassSuccessRate == 0.92)
        check("JSONValue bag reads (recent_low_score[0].score)", resp.scorecard?.recentLowScore?.first?["score"]?.doubleValue == 0.31)
        check("null→nil Int optional (recomputed)", resp.recomputed == nil)
        check("null→nil Double optional (final_efficiency_avg)", resp.scorecard?.totals?.finalEfficiencyAvg == nil)
    } catch {
        check("telemetry scorecard fixture decodes", false)
    }
}
