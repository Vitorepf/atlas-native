import Foundation

// A engine de streaming do Atlas AI — porta verbatim de lib/atlasAiStreamRuntime.ts.
// O PARSE é o núcleo de correção (golden-testável na CLB); o transporte
// (URLSession.bytes) vive no AtlasClient. Contrato SSE: frames separados por
// linha em branco; cada frame tem linhas `event:` e `data:`.
// Dispatch: AtlasAiStream+Dispatch.swift

public struct AtlasAiStreamEvent: Codable, Sendable, Equatable {
    public var id: String?
    public var traceId: String
    public var jobId: String?
    public var attemptId: String?
    public var sequence: Int
    /// `event_type` no ledger REST; no SSE ele chega como `type` e entra pelo init.
    public var eventType: String
    public var type: String { eventType }
    public var channel: String?
    public var content: String
    public var metadata: JSONObject
    public var occurredAt: String?

    public init(
        id: String? = nil,
        traceId: String,
        jobId: String? = nil,
        attemptId: String? = nil,
        sequence: Int,
        type: String,
        channel: String? = nil,
        content: String,
        metadata: JSONObject = JSONObject(),
        occurredAt: String? = nil
    ) {
        self.id = id
        self.traceId = traceId
        self.jobId = jobId
        self.attemptId = attemptId
        self.sequence = sequence
        self.eventType = type
        self.channel = channel
        self.content = content
        self.metadata = metadata
        self.occurredAt = occurredAt
    }
}

public struct AtlasAiStreamDone: Sendable, Equatable {
    public var traceId: String
    public var status: String
    public var lastSequence: Int?

    public init(traceId: String, status: String, lastSequence: Int? = nil) {
        self.traceId = traceId
        self.status = status
        self.lastSequence = lastSequence
    }
}

/// O resultado de despachar um frame. `.ignored` cobre tudo que o TS descarta
/// silenciosamente: heartbeat/timeout, frame sem `data:`, JSON inválido, e
/// event/done sem os campos obrigatórios (trace_id string + sequence number).
public enum AtlasAiStreamFrame: Sendable, Equatable {
    case event(AtlasAiStreamEvent)
    case done(AtlasAiStreamDone)
    case error(JSONValue)
    case ignored
}
