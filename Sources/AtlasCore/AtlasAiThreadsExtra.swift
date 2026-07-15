import Foundation

// Relações de thread (§346-418 de lib/api/atlasAi.ts): o estado de sessão, a
// compactação, o handoff de provider e o snapshot de contexto — mais os métodos
// de thread/interaction que faltam no loop base (createAiThread, getAiThreadState,
// compactAiThread, switchAiThreadProvider, listAiThreadSnapshots,
// feedbackAiInteraction). Mesmo contrato do decoder: `.convertFromSnakeCase`,
// zero CodingKeys, opcional em tudo que o servidor pode omitir/nulificar.
//
// AtlasAiThread / AtlasAiTrace / AiThreadResponse / AiTraceResponse vivem no
// AtlasAiModels.swift (loop de conversa) — referenciados aqui, não redefinidos.

// MARK: - DTOs de relação de thread

/// Estado estruturado vivo da thread (o "state" que o compaction hidrata). Listas
/// `unknown[]` viram `[JSONValue]?`; os bags `Record<string,unknown>` viram
/// `JSONObject?`.
public struct AtlasAiSessionState: Codable, Sendable, Identifiable {
    public let id: String
    public let threadId: String
    public let sessionId: String?
    public let version: Int
    public let active: Bool
    public let objective: String?
    public let currentPhase: String?
    public let currentTopic: String?
    public let userPosition: String?
    public let decisions: [JSONValue]?
    public let openLoops: [JSONValue]?
    public let nextSteps: [JSONValue]?
    public let relevantArtifacts: [JSONValue]?
    public let constraints: [JSONValue]?
    public let providerContext: JSONObject?
    public let qualityNotes: [JSONValue]?
    public let metadata: JSONObject?
    public let createdAt: String
    public let updatedAt: String
}

/// Registro de uma compactação de contexto (o resumo + estado estruturado que
/// substitui um trecho de mensagens). Posições e contagens de token -> Int?.
public struct AtlasAiCompaction: Codable, Sendable, Identifiable {
    public let id: String
    public let threadId: String
    public let sessionId: String?
    public let reason: String
    public let sourcePositionStart: Int?
    public let sourcePositionEnd: Int?
    public let sourceMessageCount: Int
    public let summary: String
    public let structuredState: JSONObject?
    public let tokenEstimateBefore: Int?
    public let tokenEstimateAfter: Int?
    public let qualityGateStatus: String
    public let provider: String?
    public let model: String?
    public let metadata: JSONObject?
    public let createdAt: String
    public let updatedAt: String
}

/// Handoff entre providers dentro de uma thread (o brief que carrega o contexto
/// de um provider pro próximo). `to_provider` é a união aberta `AtlasAiProvider`
/// -> String.
public struct AtlasAiProviderHandoff: Codable, Sendable, Identifiable {
    public let id: String
    public let threadId: String
    public let sessionId: String?
    public let fromProvider: String?
    public let toProvider: String
    public let reason: String
    public let briefText: String
    public let briefJson: JSONObject?
    public let compactionId: String?
    public let metadata: JSONObject?
    public let createdAt: String
    public let updatedAt: String
}

/// Snapshot imutável do contexto que foi de fato mandado a um provider numa
/// interação (auditável). Sem `updated_at` no servidor — só `created_at`.
public struct AtlasAiContextSnapshot: Codable, Sendable, Identifiable {
    public let id: String
    public let traceId: String?
    public let threadId: String?
    public let sessionId: String?
    public let provider: String?
    public let model: String?
    public let promptHash: String?
    public let contextPack: JSONObject?
    public let messagesIncluded: [JSONValue]?
    public let compactionId: String?
    public let providerHandoffId: String?
    public let tokenEstimate: Int?
    public let metadata: JSONObject?
    public let createdAt: String
}

// MARK: - Envelopes de resposta

public struct AiThreadStateResponse: Codable, Sendable { public let state: AtlasAiSessionState }
public struct AiCompactResponse: Codable, Sendable {
    public let compaction: AtlasAiCompaction
    public let thread: AtlasAiThread
}
public struct AiSwitchProviderResponse: Codable, Sendable { public let handoff: AtlasAiProviderHandoff }
public struct AiSnapshotsResponse: Codable, Sendable { public let snapshots: [AtlasAiContextSnapshot] }

/// Recibo mínimo para abrir a mesma thread/sessão em outra superfície. Não
/// contém brief, prompt, metadata, provider ou conteúdo da conversa.
public struct AtlasAiSurfaceHandoff: Codable, Sendable, Identifiable {
    public let schemaVersion: String
    public let handoffId: String
    public let threadId: String
    public let sessionId: String
    public let fromSurface: String
    public let toSurface: String
    public let status: String
    public let createdAt: String?

    public var id: String { handoffId }
}

public struct AiSurfaceHandoffResponse: Codable, Sendable {
    public let handoff: AtlasAiSurfaceHandoff
}

// MARK: - Inputs (camelCase; o encoder faz .convertToSnakeCase)

public struct CreateAiThreadInput: Encodable, Sendable {
    public var title: String?
    public var summary: String?
    public var surface: String?
    public var workspace: String?
    public var sourceType: String?
    public var sourceId: String?
    public var metadata: JSONObject?

    public init(
        title: String? = nil,
        summary: String? = nil,
        surface: String? = nil,
        workspace: String? = nil,
        sourceType: String? = nil,
        sourceId: String? = nil,
        metadata: JSONObject? = nil
    ) {
        self.title = title
        self.summary = summary
        self.surface = surface
        self.workspace = workspace
        self.sourceType = sourceType
        self.sourceId = sourceId
        self.metadata = metadata
    }
}

public struct CompactAiThreadInput: Encodable, Sendable {
    /// União aberta no .ts (manual/auto/provider_switch/…). Mantido String.
    public var reason: String?
    public var provider: String?
    public var model: String?
    public var metadata: JSONObject?

    public init(
        reason: String? = nil,
        provider: String? = nil,
        model: String? = nil,
        metadata: JSONObject? = nil
    ) {
        self.reason = reason
        self.provider = provider
        self.model = model
        self.metadata = metadata
    }
}

public struct SwitchAiThreadProviderInput: Encodable, Sendable {
    public var toProvider: String
    public var fromProvider: String?
    public var reason: String?
    public var metadata: JSONObject?

    public init(
        toProvider: String,
        fromProvider: String? = nil,
        reason: String? = nil,
        metadata: JSONObject? = nil
    ) {
        self.toProvider = toProvider
        self.fromProvider = fromProvider
        self.reason = reason
        self.metadata = metadata
    }
}

public enum AtlasAiSurfaceDestination: String, Codable, Sendable, CaseIterable {
    case mobile = "atlas_mobile"
    case desktop = "atlas_desktop"
    case terminal = "atlas_terminal"
}

public struct HandoffAiThreadSurfaceInput: Encodable, Sendable {
    public var toSurface: AtlasAiSurfaceDestination

    public init(toSurface: AtlasAiSurfaceDestination) {
        self.toSurface = toSurface
    }
}

public struct FeedbackAiInteractionInput: Encodable, Sendable {
    public var feedbackScore: Double?
    public var feedbackAction: String?
    public var feedbackComment: String?

    public init(
        feedbackScore: Double? = nil,
        feedbackAction: String? = nil,
        feedbackComment: String? = nil
    ) {
        self.feedbackScore = feedbackScore
        self.feedbackAction = feedbackAction
        self.feedbackComment = feedbackComment
    }
}

// MARK: - Métodos do client (mirror §1574-1660 de atlasAi.ts)

public extension AtlasClient {
    /// `createAiThread` (§1574). Todos os campos opcionais; corpo `{}` cria thread
    /// padrão.
    func createAiThread(_ input: CreateAiThreadInput = .init()) async throws -> AiThreadResponse {
        try await post("/ai/threads", body: input)
    }

    /// `getAiThreadState` (§1616).
    func getAiThreadState(_ id: String) async throws -> AiThreadStateResponse {
        let seg = id.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? id
        return try await get("/ai/threads/\(seg)/state")
    }

    /// `compactAiThread` (§1620).
    func compactAiThread(_ id: String, input: CompactAiThreadInput = .init()) async throws -> AiCompactResponse {
        let seg = id.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? id
        return try await post("/ai/threads/\(seg)/compact", body: input)
    }

    /// `switchAiThreadProvider` (§1632). `toProvider` é obrigatório.
    func switchAiThreadProvider(_ id: String, input: SwitchAiThreadProviderInput) async throws -> AiSwitchProviderResponse {
        let seg = id.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? id
        return try await post("/ai/threads/\(seg)/switch-provider", body: input)
    }

    /// Cria um recibo provider-safe para outra superfície abrir a mesma thread
    /// e sessão canônicas; não cria conversa, sessão ou provider novo.
    func handoffAiThreadSurface(_ id: String, input: HandoffAiThreadSurfaceInput) async throws -> AiSurfaceHandoffResponse {
        let seg = id.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? id
        return try await post("/ai/threads/\(seg)/handoff-surface", body: input)
    }

    /// `listAiThreadSnapshots` (§1644).
    func listAiThreadSnapshots(_ id: String, limit: Int? = nil) async throws -> AiSnapshotsResponse {
        let seg = id.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? id
        let q = atlasQueryString([("limit", limit.map { .int($0) })])
        return try await get("/ai/threads/\(seg)/snapshots\(q)")
    }

    /// `feedbackAiInteraction` (§1655).
    func feedbackAiInteraction(_ id: String, feedback: FeedbackAiInteractionInput) async throws -> AiTraceResponse {
        let seg = id.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? id
        return try await post("/ai/interactions/\(seg)/feedback", body: feedback)
    }
}

// MARK: - Golden checks

/// Decodifica fixtures snake_case reais e prova o contrato do decoder para o
/// cluster de relações de thread (mapeamento snake->camel, JSONValue nos bags,
/// contagens Int, null->nil).
public func runThreadsExtraChecks(_ check: (String, Bool) -> Void) {
    let dec = JSONDecoder()
    dec.keyDecodingStrategy = atlasSnakeKeyDecoding

    let stateJSON = """
    {
      "id": "st_1",
      "thread_id": "th_42",
      "session_id": null,
      "version": 3,
      "active": true,
      "objective": "ship swift port",
      "current_phase": "build",
      "current_topic": null,
      "user_position": null,
      "decisions": [{"k": "use foundation"}],
      "open_loops": [],
      "next_steps": ["typecheck"],
      "relevant_artifacts": [],
      "constraints": [],
      "provider_context": {"active_provider": "claude_cli"},
      "quality_notes": [],
      "metadata": {"pinned": true},
      "created_at": "2026-07-12T00:00:00Z",
      "updated_at": "2026-07-12T00:00:00Z"
    }
    """
    if let s = try? dec.decode(AtlasAiSessionState.self, from: Data(stateJSON.utf8)) {
        check("session state snake->camel (thread_id → threadId)", s.threadId == "th_42")
        check("session state Int version", s.version == 3)
        check("session state Bool active", s.active == true)
        check("session state null → nil optional", s.sessionId == nil && s.currentTopic == nil)
        check("session state provider_context JSONValue reads", s.providerContext?["active_provider"]?.stringValue == "claude_cli")
        check("session state metadata JSONValue + array count", s.metadata?["pinned"]?.boolValue == true && s.decisions?.count == 1)
    } else {
        check("session state decodes", false)
    }

    let compactionJSON = """
    {
      "id": "cmp_1",
      "thread_id": "th_42",
      "session_id": null,
      "reason": "auto",
      "source_position_start": 1,
      "source_position_end": 12,
      "source_message_count": 4,
      "summary": "condensed 12 messages",
      "structured_state": {"objective": "kept"},
      "token_estimate_before": 1200,
      "token_estimate_after": 300,
      "quality_gate_status": "passed",
      "provider": null,
      "model": null,
      "metadata": {},
      "created_at": "2026-07-12T00:00:00Z",
      "updated_at": "2026-07-12T00:00:00Z"
    }
    """
    if let c = try? dec.decode(AtlasAiCompaction.self, from: Data(compactionJSON.utf8)) {
        check("compaction Int counts + null → nil", c.sourceMessageCount == 4 && c.tokenEstimateBefore == 1200 && c.provider == nil)
    } else {
        check("compaction decodes", false)
    }

    let surfaceHandoffJSON = """
    {
      "handoff": {
        "schema_version": "atlas.ai.surface_handoff.v1",
        "handoff_id": "surface_1",
        "thread_id": "th_42",
        "session_id": "session_7",
        "from_surface": "atlas_mobile",
        "to_surface": "atlas_terminal",
        "status": "ready",
        "created_at": "2026-07-14T00:00:00Z"
      }
    }
    """
    if let receipt = try? dec.decode(AiSurfaceHandoffResponse.self, from: Data(surfaceHandoffJSON.utf8)) {
        check("surface handoff preserva thread e sessão canônicas", receipt.handoff.threadId == "th_42" && receipt.handoff.sessionId == "session_7")
        check("surface handoff só projeta superfícies e status público", receipt.handoff.fromSurface == "atlas_mobile" && receipt.handoff.toSurface == "atlas_terminal" && receipt.handoff.status == "ready")
    } else {
        check("surface handoff decodes", false)
    }

    let handoffEncoder = JSONEncoder()
    handoffEncoder.keyEncodingStrategy = .convertToSnakeCase
    if let data = try? handoffEncoder.encode(HandoffAiThreadSurfaceInput(toSurface: .terminal)),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
        check("surface handoff só codifica o destino permitido", json == ["to_surface": "atlas_terminal"])
    } else {
        check("surface handoff input encodes", false)
    }
}
