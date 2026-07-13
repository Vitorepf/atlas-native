import Foundation

// O centro do Atlas AI: o loop de conversa (threads → messages → sessions →
// trace) portado de lib/api/atlasAi.ts. O decoder usa `.convertFromSnakeCase`,
// então snake_case do servidor vira camelCase aqui sem CodingKeys. Todo campo
// que o servidor pode mandar `null` é opcional — senão o decode quebra.
//
// A superfície de ops (telemetry / policy / domain-catalog / cost-rates /
// observability, ~1000 linhas do .ts) é admin, não o loop de conversa. Porta
// depois; isto é o que o operador realmente usa.

/// `AtlasAiProvider | string` no TS é uma união aberta — o servidor pode mandar
/// valores fora da lista. Portanto provider/status ficam `String` (um enum
/// estrito quebraria o decode num valor novo). Constantes ficam aqui pra uso.
public enum AtlasAiProviders {
    public static let hermesCli = "hermes_cli"
    public static let claudeCli = "claude_cli"
    public static let codexCli = "codex_cli"
    public static let geminiCli = "gemini_cli"
    public static let minimax = "minimax_m27_cli"
    public static let claudeCodex = "claude_codex"
}

public struct AtlasAiSession: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let threadId: String
    public let provider: String?
    public let model: String?
    public let title: String?
    public let status: String
    public let startedAt: String?
    public let endedAt: String?
    public let metadata: JSONObject?
    public let createdAt: String
    public let updatedAt: String
}

public struct AtlasAiMessage: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let threadId: String
    public let traceId: String?
    public let position: Int
    public let role: String
    public let status: String
    public let content: String
    public let provider: String?
    public let model: String?
    public let agentSlug: String?
    public let tokenEstimate: Int?
    public let occurredAt: String?
    public let metadata: JSONObject?
    public let createdAt: String
    public let updatedAt: String
}

public struct AtlasAiThread: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let summary: String?
    public let status: String
    public let surface: String
    public let workspace: String?
    public let sourceType: String?
    public let sourceId: String?
    public let lastTraceId: String?
    public let lastProvider: String?
    public let messageCount: Int
    public let lastMessageAt: String?
    public let metadata: JSONObject?
    // Relations pesadas (light=true as omite). Porta o resto do grafo depois.
    public let messages: [AtlasAiMessage]?
    public let activeSession: AtlasAiSession?
    public let createdAt: String
    public let updatedAt: String
}

/// O que `createAiInteraction`/`getAiInteraction` retornam. Campos escalares do
/// centro; o grafo pesado (router_decision, atlas_decision, decision_receipt,
/// quality_evaluation, attempt_history) fica em `metadata`/porta depois.
public struct AtlasAiTrace: Codable, Sendable, Identifiable {
    public let id: String
    public let traceKey: String
    public let threadId: String?
    public let sessionId: String?
    public let status: String
    public let operatorInput: String
    public let intent: String?
    public let agentSlug: String
    public let provider: String?
    public let model: String?
    public let responseText: String?
    public let latencyMs: Int?
    public let completedAt: String?
    public let metadata: JSONObject?
    // Execução — a "orquestra" (jobs = agentes/providers/modelos) + o estágio do
    // Atlas Decide. Ligados para a Ribbon de Execução (transparência agêntica).
    public let jobs: [AtlasAiJob]?
    public let atlasDecideExecution: AtlasAiExecutionState?
    public let createdAt: String
    public let updatedAt: String
}

// MARK: - Envelopes de resposta

public struct AiThreadsResponse: Codable, Sendable { public let threads: [AtlasAiThread] }
public struct AiThreadResponse: Codable, Sendable { public let thread: AtlasAiThread }
public struct AiInteractionsResponse: Codable, Sendable { public let traces: [AtlasAiTrace] }
public struct AiTraceResponse: Codable, Sendable { public let trace: AtlasAiTrace }

// MARK: - Input de criação (só o caminho JSON; upload em chunks precisa de
// FileSystem do device e porta depois — createAiInteraction §1219 do .ts).

public struct CreateAiInteractionInput: Encodable, Sendable {
    public var inputText: String
    public var clientId: String?
    public var threadId: String?
    public var sessionId: String?
    public var newThread: Bool?
    public var agentSlug: String?
    public var provider: String?
    public var kind: String?
    public var sourceType: String?
    public var sourceId: String?
    public var priority: Int?
    public var includeSemanticContext: Bool?
    public var contextNoteLimit: Int?
    public var payload: JSONObject?
    // Anexos — LIÇÃO DURA do servidor: uploaded_images/uploaded_documents no
    // NÍVEL RAIZ é o que ANEXA de verdade (ids do upload chunked); o
    // rich_input_payload é espelho para routing (detecção de visão) + audit.
    public var uploadedImages: [String]?
    public var uploadedDocuments: [String]?
    public var richInputPayload: AtlasRichInputPayload?

    public init(
        inputText: String,
        clientId: String? = nil,
        threadId: String? = nil,
        sessionId: String? = nil,
        newThread: Bool? = nil,
        agentSlug: String? = nil,
        provider: String? = nil,
        kind: String? = nil,
        sourceType: String? = nil,
        sourceId: String? = nil,
        priority: Int? = nil,
        includeSemanticContext: Bool? = nil,
        contextNoteLimit: Int? = nil,
        payload: JSONObject? = nil,
        uploadedImages: [String]? = nil,
        uploadedDocuments: [String]? = nil,
        richInputPayload: AtlasRichInputPayload? = nil
    ) {
        self.inputText = inputText
        self.clientId = clientId
        self.threadId = threadId
        self.sessionId = sessionId
        self.newThread = newThread
        self.agentSlug = agentSlug
        self.provider = provider
        self.kind = kind
        self.sourceType = sourceType
        self.sourceId = sourceId
        self.priority = priority
        self.includeSemanticContext = includeSemanticContext
        self.contextNoteLimit = contextNoteLimit
        self.payload = payload
        self.uploadedImages = uploadedImages
        self.uploadedDocuments = uploadedDocuments
        self.richInputPayload = richInputPayload
    }
}
