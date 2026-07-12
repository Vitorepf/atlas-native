import Foundation

// A representative slice of the DTOs (the full ~403 come from codegen off
// lib/api/client.ts — plano §8). These carry exactly what the merge core needs
// plus their domain sort key, and prove the Codable + merge shape end-to-end.
//
// Properties are camelCase; decode server snake_case with
// `decoder.keyDecodingStrategy = .convertFromSnakeCase` (see AtlasClient).

public struct AtlasCapture: Codable, Equatable, ClientMergeable, Sendable {
    public var id: String?
    public var clientId: String
    public var updatedAt: String
    public var deletedAt: String?
    public var capturedAt: String
    public var contentText: String?
    public var metadata: [String: JSONValue]?

    public init(id: String? = nil, clientId: String, updatedAt: String, deletedAt: String? = nil,
                capturedAt: String, contentText: String? = nil, metadata: [String: JSONValue]? = nil) {
        self.id = id; self.clientId = clientId; self.updatedAt = updatedAt; self.deletedAt = deletedAt
        self.capturedAt = capturedAt; self.contentText = contentText; self.metadata = metadata
    }
}

public struct AtlasCheckin: Codable, Equatable, ClientMergeable, Sendable {
    public var id: String?
    public var clientId: String
    public var updatedAt: String
    public var deletedAt: String?
    public var recordedAt: String
    public var state: String?

    public init(id: String? = nil, clientId: String, updatedAt: String, deletedAt: String? = nil,
                recordedAt: String, state: String? = nil) {
        self.id = id; self.clientId = clientId; self.updatedAt = updatedAt; self.deletedAt = deletedAt
        self.recordedAt = recordedAt; self.state = state
    }
}

// Per-type wrappers — verbatim behavioural ports of storeConverters.ts.
// captures sort DESC by captured_at; checkins sort DESC by recorded_at.
public func mergeCaptures(_ captures: [AtlasCapture]) -> [AtlasCapture] {
    Merge.byClientId(captures) { AtlasTime.ms($0.capturedAt) }
}

public func mergeCheckins(_ checkins: [AtlasCheckin]) -> [AtlasCheckin] {
    Merge.byClientId(checkins) { AtlasTime.ms($0.recordedAt) }
}
