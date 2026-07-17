import Foundation

public enum AtlasInteractionSteerRejectionReason: String, Codable, Sendable, Equatable, CaseIterable {
    case instructionRequired = "instruction_required"
    case invalidScope = "invalid_scope"
    case traceWithoutThread = "trace_without_thread"
    case noActiveJob = "no_active_job"
}

public enum AtlasInteractionSteerDeliveryStatus: String, Codable, Sendable, Equatable {
    case queuedForNextSafeCheckpoint = "queued_for_next_safe_checkpoint"
    case notQueued = "not_queued"
}

public struct AtlasInteractionSteerDelivery: Codable, Sendable, Equatable {
    public let status: AtlasInteractionSteerDeliveryStatus
}
