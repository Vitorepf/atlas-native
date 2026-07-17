import Foundation

/// SD-1: projeção pública mínima para qualquer superfície fora do app.
/// Widgets leem só este arquivo no App Group; ausência/versão errada falha
/// fechado para "abra o Atlas".
/// Nested types: AtlasNativeSnapshot+Nested.swift
public struct AtlasNativeSnapshot: Codable, Sendable, Equatable {
    public static let schemaVersion = "atlas.native.snapshot.v1"
    public static let appGroupIdentifier = "group.com.vitor.atlas.native"
    public static let relativePath = "snapshot/atlas.native.snapshot.v1.json"

    public let schemaVersion: String
    public let generatedAt: Date
    public let liveSessions: [LiveSession]?
    public let fleet: Fleet?
    public let week: Week?
    public let queuedCount: Int?

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case generatedAt = "generated_at"
        case liveSessions = "live_sessions"
        case fleet
        case week
        case queuedCount = "queued_count"
    }

    public init(
        generatedAt: Date,
        liveSessions: [LiveSession]? = nil,
        fleet: Fleet? = nil,
        week: Week? = nil,
        queuedCount: Int? = nil
    ) {
        self.schemaVersion = Self.schemaVersion
        self.generatedAt = generatedAt
        self.liveSessions = liveSessions
        self.fleet = fleet
        self.week = week
        self.queuedCount = queuedCount
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try values.requireSchema(Self.schemaVersion, forKey: .schemaVersion, message: "Unsupported Atlas Native snapshot schema.")
        generatedAt = try values.decode(Date.self, forKey: .generatedAt)
        liveSessions = try values.decodeIfPresent([LiveSession].self, forKey: .liveSessions)
        fleet = try values.decodeIfPresent(Fleet.self, forKey: .fleet)
        week = try values.decodeIfPresent(Week.self, forKey: .week)
        queuedCount = try values.decodeIfPresent(Int.self, forKey: .queuedCount)
    }
}
