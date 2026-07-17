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
    public let retryAfterSeconds: Int?
    public init(status: Int, path: String, message: String, retryAfterSeconds: Int? = nil) {
        self.status = status
        self.path = path
        self.message = message
        self.retryAfterSeconds = retryAfterSeconds
    }
    public var description: String { "AtlasApiError(\(status), \(path)): \(message)" }
}

public struct AtlasRawDataResponse: Sendable {
    public let data: Data
    public let status: Int
    public let contentType: String
    public let atlasSha256: String?
}

public struct AtlasNetworkPathCost: Sendable, Equatable {
    public let isExpensive: Bool
    public let isConstrained: Bool

    public init(isExpensive: Bool = false, isConstrained: Bool = false) {
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
    }
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
    private var pathCost = AtlasNetworkPathCost()

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

    public func setNetworkPathCost(_ cost: AtlasNetworkPathCost) {
        pathCost = cost
    }

    private func adjustedTimeout(_ timeout: TimeInterval) -> TimeInterval {
        Self.adaptiveTimeout(timeout, cost: pathCost)
    }

    public static func adaptiveTimeout(_ timeout: TimeInterval, cost: AtlasNetworkPathCost) -> TimeInterval {
        let multiplier: TimeInterval
        switch (cost.isExpensive, cost.isConstrained) {
        case (true, true): multiplier = 2.0
        case (_, true): multiplier = 1.75
        case (true, false): multiplier = 1.35
        case (false, false): multiplier = 1.0
        }
        return min(max(timeout * multiplier, timeout), 600)
    }

    // MARK: - Verbs (mirror apiGet/apiPost/apiPatch/apiDelete)

    public func get<T: Decodable>(_ path: String, auth: Bool = true) async throws -> T {
        try await request(path, method: "GET", body: nil, auth: auth)
    }

    public func getData(_ path: String, auth: Bool = true, timeout: TimeInterval = 15) async throws -> AtlasRawDataResponse {
        let timeout = adjustedTimeout(timeout)
        guard let url = URL(string: config.base + path) else {
            throw AtlasApiError(status: 0, path: path, message: "URL inválida")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = timeout
        req.setValue("*/*", forHTTPHeaderField: "Accept")
        if auth { req.setValue(config.token, forHTTPHeaderField: "X-Atlas-Token") }

        let (data, response) = try await session.data(for: req)
        let http = response as? HTTPURLResponse
        let status = http?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            throw AtlasApiError(
                status: status,
                path: path,
                message: Self.errorMessage(data) ?? "HTTP \(status)",
                retryAfterSeconds: Self.retryAfterSeconds(from: http)
            )
        }

        return AtlasRawDataResponse(
            data: data,
            status: status,
            contentType: http?.value(forHTTPHeaderField: "Content-Type") ?? "application/octet-stream",
            atlasSha256: http?.value(forHTTPHeaderField: "X-Atlas-Sha256")
        )
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
        let timeout = adjustedTimeout(timeout)
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
        let http = response as? HTTPURLResponse
        let status = http?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            throw AtlasApiError(
                status: status,
                path: path,
                message: Self.errorMessage(data) ?? "HTTP \(status)",
                retryAfterSeconds: Self.retryAfterSeconds(from: http)
            )
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

    static func retryAfterSeconds(from response: HTTPURLResponse?) -> Int? {
        guard let raw = response?.value(forHTTPHeaderField: "Retry-After")?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return nil }
        if let seconds = Int(raw), seconds >= 0 { return seconds }
        if let date = HTTPDateParser.date(from: raw) {
            return max(0, Int(ceil(date.timeIntervalSinceNow)))
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
        let adjustedWindow = Int(adjustedTimeout(TimeInterval(timeoutSeconds)).rounded(.up))
        return AsyncThrowingStream { continuation in
            let timeout = min(max(adjustedWindow, 5), 600)
            let cursor = max(0, after)
            let path = AtlasRoute.aiInteractionStream(traceId, timeout: timeout, after: cursor)
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

    /// M07 · Steer de uma execução viva. O contrato publica tanto o aceite 202
    /// quanto a rejeição governada 422 no mesmo schema, então este caminho
    /// decodifica ambos e só transforma outros HTTP em `AtlasApiError`.
    /// (Fica no core: precisa de config/session/encoder/decoder privados.)
    public func steerAiInteraction(
        _ id: String,
        input: AtlasInteractionSteerInput
    ) async throws -> AtlasInteractionSteerResponse {
        let path = AtlasRoute.aiInteractionSteer(id)
        guard let url = URL(string: config.base + path) else {
            throw AtlasApiError(status: 0, path: path, message: "URL inválida")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 15
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(config.token, forHTTPHeaderField: "X-Atlas-Token")
        req.httpBody = try encoder.encode(input)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: req)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard status == 202 || status == 422 else {
            throw AtlasApiError(status: status, path: path, message: Self.errorMessage(data) ?? "HTTP \(status)")
        }
        return try decoder.decode(AtlasInteractionSteerResponse.self, from: data)
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

private enum HTTPDateParser {
    static func date(from value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss zzz"
        return formatter.date(from: value)
    }
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
    private static let lfDelimiter = Data([0x0A, 0x0A])
    private static let crlfDelimiter = Data([0x0D, 0x0A, 0x0D, 0x0A])

    private let traceId: String
    private let path: String
    private let continuation: AsyncThrowingStream<AtlasAiStreamFrame, Error>.Continuation
    private let decoder = JSONDecoder()
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
        var cursor = buffer.startIndex
        var consumedEnd: Data.Index?
        while let range = firstDelimiter(in: buffer, from: cursor) {
            let frameData = buffer[cursor..<range.lowerBound]
            dispatch(frameData)
            cursor = range.upperBound
            consumedEnd = range.upperBound
        }
        if let consumedEnd {
            buffer.removeSubrange(..<consumedEnd)
        }
    }

    private func drainRemainder() {
        guard !buffer.isEmpty else { return }
        let remainder = buffer
        buffer.removeAll(keepingCapacity: false)
        dispatch(remainder)
    }

    private func dispatch(_ data: Data) {
        guard !data.isEmpty else { return }
        emit(dispatchAtlasAiStreamFrame(data, decoder: decoder), traceId: traceId, into: continuation)
    }

    private func firstDelimiter(in data: Data, from start: Data.Index) -> Range<Data.Index>? {
        let searchRange = start..<data.endIndex
        let lf = data.range(of: Self.lfDelimiter, options: [], in: searchRange)
        let crlf = data.range(of: Self.crlfDelimiter, options: [], in: searchRange)
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
