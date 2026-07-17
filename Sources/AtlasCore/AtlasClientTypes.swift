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

/// Slice of the `/health` envelope — enough to prove the engine end-to-end.
public struct AtlasHealthResponse: Decodable, Sendable {
    public let status: String
    public let service: String?
    public let version: String?
    public let overallOk: Bool?
    public let dbConnected: Bool?
}
