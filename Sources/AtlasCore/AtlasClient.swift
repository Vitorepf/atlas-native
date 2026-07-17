import Foundation

/// The request engine — the Swift analog of `apiRequest<T>` (lib/api/core.ts).
/// `URLSession` + async/await + `Codable`. Auth via `X-Atlas-Token` (the lane
/// the /ai/* surface uses; the mobile Bearer lane ports with device pairing).
/// Retry+backoff and the 401→clear-pairing invariant layer on next.
public actor AtlasClient: AtlasAiStreamSource {
    let config: AtlasConfig
    let session: URLSession
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    var pathCost = AtlasNetworkPathCost()

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

    func adjustedTimeout(_ timeout: TimeInterval) -> TimeInterval {
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
}
