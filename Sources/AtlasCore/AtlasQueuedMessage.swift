import Foundation

/// DTO da fila de follow-up — peel de `AtlasQueuedFollowUp.swift`.
public struct QueuedMessage: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let text: String
    public let createdAt: Date

    public init(id: String = UUID().uuidString.lowercased(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}
