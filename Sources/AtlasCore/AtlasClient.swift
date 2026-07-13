import Foundation

/// Config resolved from the same sources the RN app uses (expo `extra.atlas` /
/// env / Keychain). Base URL logic mirrors `getApiBase()` in lib/api/core.ts.
public struct AtlasConfig: Sendable {
    public var host: String
    public var port: Int
    public var token: String

    public init(host: String = "127.0.0.1", port: Int = 3737, token: String = "") {
        self.host = host; self.port = port; self.token = token
    }

    public var base: String {
        let h = host.hasSuffix("/") ? String(host.dropLast()) : host
        if h.hasPrefix("http://") || h.hasPrefix("https://") { return h }
        return "http://\(h):\(port)"
    }
}

/// Mirrors `AtlasApiError` (lib/api/core.ts): status + path + a message pulled
/// from the server's `.message` / `.error.message` / `.errors{}` envelope.
public struct AtlasApiError: Error, CustomStringConvertible, Sendable {
    public let status: Int
    public let path: String
    public let message: String
    public init(status: Int, path: String, message: String) {
        self.status = status
        self.path = path
        self.message = message
    }
    public var description: String { "AtlasApiError(\(status), \(path)): \(message)" }
}

/// The request engine — the Swift analog of `apiRequest<T>` (lib/api/core.ts).
/// `URLSession` + async/await + `Codable`. Auth via `X-Atlas-Token` (the lane
/// the /ai/* surface uses; the mobile Bearer lane ports with device pairing).
/// Retry+backoff and the 401→clear-pairing invariant layer on next.
public actor AtlasClient: AtlasAiStreamSource {
    private let config: AtlasConfig
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(config: AtlasConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
        let d = JSONDecoder()
        d.keyDecodingStrategy = atlasSnakeKeyDecoding   // kills CodingKeys on the DTOs
        self.decoder = d
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase     // inputText → input_text, etc.
        self.encoder = e
    }

    // MARK: - Verbs (mirror apiGet/apiPost/apiPatch/apiDelete)

    public func get<T: Decodable>(_ path: String, auth: Bool = true) async throws -> T {
        try await request(path, method: "GET", body: nil, auth: auth)
    }

    public func post<T: Decodable, B: Encodable>(_ path: String, body: B, auth: Bool = true, timeout: TimeInterval = 15) async throws -> T {
        try await request(path, method: "POST", body: try encoder.encode(body), auth: auth, timeout: timeout)
    }

    /// POST com corpo `{}` — os endpoints retry/cancel/feedback/run do .ts.
    public func post<T: Decodable>(_ path: String, auth: Bool = true) async throws -> T {
        try await request(path, method: "POST", body: Data("{}".utf8), auth: auth)
    }

    public func patch<T: Decodable, B: Encodable>(_ path: String, body: B, auth: Bool = true) async throws -> T {
        try await request(path, method: "PATCH", body: try encoder.encode(body), auth: auth)
    }

    public func delete<T: Decodable>(_ path: String, auth: Bool = true) async throws -> T {
        try await request(path, method: "DELETE", body: nil, auth: auth)
    }

    private func request<T: Decodable>(_ path: String, method: String, body: Data?, auth: Bool, timeout: TimeInterval = 15) async throws -> T {
        guard let url = URL(string: config.base + path) else {
            throw AtlasApiError(status: 0, path: path, message: "URL inválida")
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = timeout
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if auth { req.setValue(config.token, forHTTPHeaderField: "X-Atlas-Token") }
        if let body {
            req.httpBody = body
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            throw AtlasApiError(status: status, path: path, message: Self.errorMessage(data) ?? "HTTP \(status)")
        }
        return try decoder.decode(T.self, from: data)
    }

    /// Lenient error-envelope reader: `.message` → `.error.message` → first of `.errors`.
    static func errorMessage(_ data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        if let m = obj["message"] as? String { return m }
        if let e = obj["error"] as? [String: Any], let m = e["message"] as? String { return m }
        if let errs = obj["errors"] as? [String: Any], let first = errs.values.first {
            if let arr = first as? [String], let m = arr.first { return m }
            if let s = first as? String { return s }
        }
        return nil
    }

    // MARK: - Live SSE stream (transporte de `streamAiInteraction`)

    /// Abre o stream de uma interação e emite frames tipados conforme chegam.
    /// `URLSession.bytes.lines` já faz o framing SSE (linha em branco = fim de
    /// frame). Filtra por traceId como o wrapper do .ts. ponytail: conexão
    /// única; reconnect+backoff (maxReconnects=4 no .ts) é o upgrade de
    /// resiliência quando o SSE cair em runs longas.
    public func streamInteraction(
        traceId: String,
        after: Int = 0,
        timeoutSeconds: Int = 120,
        maxReconnects: Int = 4
    ) -> AsyncThrowingStream<AtlasAiStreamFrame, Error> {
        makeAtlasResumableInteractionStream(
            source: self,
            traceId: traceId,
            after: after,
            timeoutSeconds: timeoutSeconds,
            policy: AtlasStreamReconnectPolicy(maxReconnects: maxReconnects)
        )
    }

    public func openInteractionStreamOnce(
        traceId: String,
        after: Int,
        timeoutSeconds: Int
    ) async throws -> AsyncThrowingStream<AtlasAiStreamFrame, Error> {
        let cfg = config
        return AsyncThrowingStream { continuation in
            let timeout = min(max(timeoutSeconds, 5), 600)
            let cursor = max(0, after)
            let encoded = traceId.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? traceId
            let path = "/ai/interactions/\(encoded)/stream?timeout=\(timeout)&after=\(cursor)"
            guard let url = URL(string: cfg.base + path) else {
                continuation.finish(throwing: AtlasApiError(status: 0, path: path, message: "URL inválida"))
                return
            }

            var request = URLRequest(url: url)
            request.timeoutInterval = TimeInterval(timeout + 15)
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
            request.setValue(cfg.token, forHTTPHeaderField: "X-Atlas-Token")

            // `URLSession.bytes.lines` devolveu corpo vazio contra o stream PHP
            // real no device/macOS, embora curl recebesse os frames. O delegate
            // é o caminho nativo realmente incremental: cada `didReceive data`
            // alimenta o framing SSE sem esperar a resposta terminar.
            let delegate = AtlasSSESessionDelegate(
                traceId: traceId,
                path: path,
                continuation: continuation
            )
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = TimeInterval(timeout + 15)
            configuration.timeoutIntervalForResource = TimeInterval(timeout + 15)
            let streamSession = URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
            let task = streamSession.dataTask(with: request)
            continuation.onTermination = { _ in
                task.cancel()
                streamSession.invalidateAndCancel()
                _ = delegate
            }
            task.resume()
        }
    }

    // MARK: - Atlas AI: o loop de conversa (mirror de atlasAi.ts)

    public func listAiThreads(
        status: String? = nil, surface: String? = nil, workspace: String? = nil,
        includeMessages: Bool? = nil, light: Bool? = nil, limit: Int? = nil
    ) async throws -> AiThreadsResponse {
        let q = atlasQueryString([
            ("status", status.map { .string($0) }),
            ("surface", surface.map { .string($0) }),
            ("workspace", workspace.map { .string($0) }),
            ("include_messages", includeMessages.map { .bool($0) }),
            ("light", light.map { .bool($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("/ai/threads\(q)")
    }

    public func getAiThread(_ id: String) async throws -> AiThreadResponse {
        try await get("/ai/threads/\(pathEncode(id))")
    }

    public func updateAiThread(_ id: String, patch: [String: JSONValue]) async throws -> AiThreadResponse {
        try await self.patch("/ai/threads/\(pathEncode(id))", body: patch)
    }

    public func deleteAiThread(_ id: String) async throws -> JSONValue {
        try await delete("/ai/threads/\(pathEncode(id))")
    }

    public func listAiInteractions(
        threadId: String? = nil, status: String? = nil, agent: String? = nil,
        clientId: String? = nil, limit: Int? = nil
    ) async throws -> AiInteractionsResponse {
        let q = atlasQueryString([
            ("thread_id", threadId.map { .string($0) }),
            ("status", status.map { .string($0) }),
            ("agent", agent.map { .string($0) }),
            ("client_id", clientId.map { .string($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("/ai/interactions\(q)")
    }

    public func getAiInteraction(_ id: String) async throws -> AiTraceResponse {
        try await get("/ai/interactions/\(pathEncode(id))")
    }

    /// Caminho JSON de `createAiInteraction` (sem anexos). Upload em chunks
    /// precisa do FileSystem do device — porta com a camada de anexos.
    public func createAiInteraction(_ input: CreateAiInteractionInput) async throws -> AiTraceResponse {
        // O create é síncrono e pesado (monta contexto semântico; com DOCUMENTO
        // ainda extrai PDF/OCR antes do 202): 15s default estoura o -1001.
        // 90s sem documentos, 120s com.
        let hasDocuments = !(input.uploadedDocuments ?? []).isEmpty
        return try await post("/ai/interactions", body: input, timeout: hasDocuments ? 120 : 90)
    }

    // MARK: - Live Activities remotas (APNs)

    /// Registra o token ROTATIVO de uma ActivityKit Live Activity para o trace
    /// já criado. O servidor recebe somente o token necessário para APNs e
    /// devolve um receipt sem material sensível.
    public func registerLiveActivity(
        _ input: AtlasLiveActivityRegistrationInput
    ) async throws -> AtlasLiveActivityRegistrationReceipt {
        let response: AtlasLiveActivityRegistrationResponse = try await post("/ai/live-activities", body: input)
        return response.registration
    }

    /// Registra/rotaciona o token que permite iniciar uma ActivityKit remota
    /// para esta instalação quando uma missão começa pelo Terminal/CLI.
    public func registerLiveActivityStartToken(
        _ input: AtlasLiveActivityStartTokenInput
    ) async throws -> AtlasLiveActivityStartTokenReceipt {
        let response: AtlasLiveActivityStartTokenResponse = try await post(
            "/ai/live-activities/start-tokens", body: input
        )
        return response.registration
    }

    /// Invalida um token quando a Live Activity acaba localmente. A chamada é
    /// idempotente: falha de rede não muda a verdade local nem reativa o token.
    public func invalidateLiveActivity(
        activityId: String,
        input: AtlasLiveActivityInvalidationInput
    ) async throws -> AtlasLiveActivityRegistrationReceipt {
        let response: AtlasLiveActivityRegistrationResponse = try await post(
            "/ai/live-activities/\(pathEncode(activityId))/invalidate",
            body: input
        )
        return response.registration
    }

    private func pathEncode(_ s: String) -> String {
        s.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? s
    }
}

/// Slice of the `/health` envelope — enough to prove the engine end-to-end.
public struct AtlasHealthResponse: Decodable, Sendable {
    public let status: String
    public let service: String?
    public let version: String?
    public let overallOk: Bool?
    public let dbConnected: Bool?
}

// MARK: - queryString (verbatim de core.ts)

public enum QueryValue: Sendable {
    case string(String)
    case int(Int)
    case bool(Bool)
}

/// Porta de `queryString(params)` + `normalizeQueryValue` (lib/api/core.ts).
/// Gotchas fiéis: pula nil/""; `limit` numérico é clampado a [1,200]; boolean
/// vira "1"/"0" (Laravel `boolean` rejeita "true"/"false" → 422).
public func atlasQueryString(_ items: [(String, QueryValue?)]) -> String {
    var pairs: [(String, String)] = []
    for (key, value) in items {
        guard let normalized = normalizeQueryValue(key, value) else { continue }
        pairs.append((key, normalized))
    }
    if pairs.isEmpty { return "" }
    return "?" + pairs.map { "\(uriEncode($0.0))=\(uriEncode($0.1))" }.joined(separator: "&")
}

private func normalizeQueryValue(_ key: String, _ value: QueryValue?) -> String? {
    guard let value else { return nil }
    switch value {
    case .string(let s):
        return s.isEmpty ? nil : s
    case .int(let n):
        if key == "limit" { return String(min(200, max(1, n))) }
        return String(n)
    case .bool(let b):
        return b ? "1" : "0"
    }
}

/// Conjunto de `encodeURIComponent`: deixa `A-Za-z0-9-_.!~*'()`.
let encodeURIComponentAllowed: CharacterSet = {
    var s = CharacterSet.alphanumerics
    s.insert(charactersIn: "-_.!~*'()")
    return s
}()

private func uriEncode(_ s: String) -> String {
    s.addingPercentEncoding(withAllowedCharacters: encodeURIComponentAllowed) ?? s
}

/// Aplica o filtro do wrapper `streamAiInteraction`: event/done com trace_id
/// diferente do pedido são descartados; error/ignored passam.
private func emit(
    _ frame: AtlasAiStreamFrame,
    traceId: String,
    into continuation: AsyncThrowingStream<AtlasAiStreamFrame, Error>.Continuation
) {
    switch frame {
    case .event(let e) where e.traceId != traceId: return
    case .done(let d) where d.traceId != traceId: return
    default: continuation.yield(frame)
    }
}

private final class AtlasSSESessionDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private let traceId: String
    private let path: String
    private let continuation: AsyncThrowingStream<AtlasAiStreamFrame, Error>.Continuation
    private var buffer = Data()
    private var finished = false

    init(
        traceId: String,
        path: String,
        continuation: AsyncThrowingStream<AtlasAiStreamFrame, Error>.Continuation
    ) {
        self.traceId = traceId
        self.path = path
        self.continuation = continuation
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            finish(throwing: AtlasApiError(status: status, path: path, message: "Atlas stream \(status)"))
            completionHandler(.cancel)
            return
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard !finished else { return }
        buffer.append(data)
        drainCompleteFrames()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard !finished else { return }
        if let error {
            if (error as? URLError)?.code == .cancelled { finish() }
            else { finish(throwing: error) }
            return
        }
        drainRemainder()
        finish()
    }

    private func drainCompleteFrames() {
        while let range = firstDelimiter(in: buffer) {
            let frameData = Data(buffer[..<range.lowerBound])
            buffer.removeSubrange(..<range.upperBound)
            dispatch(frameData)
        }
    }

    private func drainRemainder() {
        guard !buffer.isEmpty else { return }
        let remainder = buffer
        buffer.removeAll(keepingCapacity: false)
        dispatch(remainder)
    }

    private func dispatch(_ data: Data) {
        guard let frame = String(data: data, encoding: .utf8), !frame.isEmpty else { return }
        emit(dispatchAtlasAiStreamFrame(frame), traceId: traceId, into: continuation)
    }

    private func firstDelimiter(in data: Data) -> Range<Data.Index>? {
        let lf = data.range(of: Data("\n\n".utf8))
        let crlf = data.range(of: Data("\r\n\r\n".utf8))
        switch (lf, crlf) {
        case (.some(let a), .some(let b)): return a.lowerBound < b.lowerBound ? a : b
        case (.some(let a), .none): return a
        case (.none, .some(let b)): return b
        case (.none, .none): return nil
        }
    }

    private func finish(throwing error: Error? = nil) {
        guard !finished else { return }
        finished = true
        if let error { continuation.finish(throwing: error) }
        else { continuation.finish() }
    }
}
