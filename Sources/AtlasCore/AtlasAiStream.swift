import Foundation

// A engine de streaming do Atlas AI — porta verbatim de lib/atlasAiStreamRuntime.ts.
// O PARSE é o núcleo de correção (golden-testável na CLB); o transporte
// (URLSession.bytes) vive no AtlasClient. Contrato SSE: frames separados por
// linha em branco; cada frame tem linhas `event:` e `data:`.

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

/// Verbatim de `parseAtlasAiSseFrames`: split por linha-em-branco, trim, drop vazios.
/// (`/\r?\n\r?\n/` → normaliza CR e quebra em "\n\n".)
public func parseAtlasAiSseFrames(_ text: String) -> [String] {
    let normalized = text.replacingOccurrences(of: "\r", with: "")
    return normalized
        .components(separatedBy: "\n\n")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}

/// Verbatim de `dispatchAtlasAiStreamFrame`. Um frame → um resultado tipado.
/// Fidelidade que importa (todos exercitados nos golden checks):
/// - eventName default é "message"; `event:`/`data:` são lidos por prefixo.
/// - sem linha `data:` → `.ignored`.
/// - JSON inválido → `.ignored` (o TS faz `try/catch` e retorna).
/// - `done` exige trace_id:string E status:string; senão `.ignored`.
/// - `error` emite o payload cru.
/// - `heartbeat`/`timeout` → `.ignored`.
/// - event exige trace_id:string E sequence:number; `type` cai pro eventName,
///   `content` cai pra "", `metadata` cai pra {}.
public func dispatchAtlasAiStreamFrame(_ frame: String) -> AtlasAiStreamFrame {
    dispatchAtlasAiStreamFrame(frame, decoder: JSONDecoder())
}

public func dispatchAtlasAiStreamFrame(_ frame: String, decoder: JSONDecoder) -> AtlasAiStreamFrame {
    var eventName = "message"
    var dataLines: [String] = []

    for rawLine in frame.components(separatedBy: "\n") {
        let line = trimTrailingWhitespace(rawLine)
        if line.hasPrefix("event:") {
            eventName = String(line.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if line.hasPrefix("data:") {
            dataLines.append(trimLeadingWhitespace(String(line.dropFirst(5))))
        }
    }

    if dataLines.isEmpty { return .ignored }

    guard let payloadData = dataLines.joined(separator: "\n").data(using: .utf8),
          let payload = try? decoder.decode(JSONValue.self, from: payloadData) else {
        return .ignored
    }

    return dispatchAtlasAiStreamPayload(payload, eventName: eventName)
}

func dispatchAtlasAiStreamPayload(_ payload: JSONValue, eventName: String) -> AtlasAiStreamFrame {
    if eventName == "done" {
        if let traceId = payload["trace_id"]?.stringValue,
           let status = payload["status"]?.stringValue {
            let last = payload["last_sequence"]?.doubleValue
            return .done(AtlasAiStreamDone(
                traceId: traceId,
                status: status,
                lastSequence: last.map { Int($0) }))
        }
        return .ignored
    }

    if eventName == "error" { return .error(payload) }
    if eventName == "heartbeat" || eventName == "timeout" { return .ignored }

    guard let traceId = payload["trace_id"]?.stringValue,
          let sequence = payload["sequence"]?.doubleValue else {
        return .ignored
    }

    let metadata: JSONObject
    if case .object(let obj)? = payload["metadata"] { metadata = JSONObject(obj) } else { metadata = JSONObject() }

    return .event(AtlasAiStreamEvent(
        id: payload["id"]?.stringValue,
        traceId: traceId,
        jobId: payload["job_id"]?.stringValue,
        attemptId: payload["attempt_id"]?.stringValue,
        sequence: Int(sequence),
        type: payload["type"]?.stringValue ?? eventName,
        channel: payload["channel"]?.stringValue,
        content: payload["content"]?.stringValue ?? "",
        metadata: metadata,
        occurredAt: payload["occurred_at"]?.stringValue))
}

private func trimTrailingWhitespace(_ s: String) -> String {
    var out = s
    while let last = out.last, last.isWhitespace { out.removeLast() }
    return out
}

private func trimLeadingWhitespace(_ s: String) -> String {
    var out = Substring(s)
    while let first = out.first, first.isWhitespace { out = out.dropFirst() }
    return String(out)
}
