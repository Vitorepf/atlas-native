import Foundation

// Envelopes de resposta e input de criação — peel de AtlasAiModels (régua ~160).
// O núcleo do loop (Session/Message/Thread/Trace) fica no arquivo principal.

// MARK: - Envelopes de resposta

public struct AiThreadsResponse: Codable, Sendable { public let threads: [AtlasAiThread] }
public struct AiThreadResponse: Codable, Sendable { public let thread: AtlasAiThread }
public struct AiInteractionsResponse: Codable, Sendable { public let traces: [AtlasAiTrace] }
public struct AiTraceResponse: Codable, Sendable { public let trace: AtlasAiTrace }

// MARK: - Input de criação (só o caminho JSON; upload em chunks precisa de
// FileSystem do device e porta depois — createAiInteraction §1219 do .ts).

public struct CreateAiInteractionInput: Codable, Sendable {
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
