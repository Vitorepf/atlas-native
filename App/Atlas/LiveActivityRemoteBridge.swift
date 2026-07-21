import ActivityKit
import AtlasCore
import Foundation

// Cycle 040 fuse → LiveActivityRemoteBridge.swift

#if canImport(ActivityKit)

/// Transporte APNs de uma Live Activity já iniciada na tela local.
///
@MainActor
final class LiveActivityRemoteBridge {
    static let shared = LiveActivityRemoteBridge()
    private init() {}

    var tokenTasks: [String: Task<Void, Never>] = [:]
    var tracesByActivityID: [String: TraceID] = [:]
    var locallyManagedActivityIDs: Set<String> = []
    var startTokenTask: Task<Void, Never>?
    var remoteActivityTask: Task<Void, Never>?
}
#endif
