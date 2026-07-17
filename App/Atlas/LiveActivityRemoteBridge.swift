import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit

/// Transporte APNs de uma Live Activity já iniciada na tela local.
///
/// Observe → LiveActivityRemoteBridge+BridgeObserve.swift
/// End → LiveActivityRemoteBridge+BridgeEnd.swift
/// Wait → LiveActivityRemoteBridge+BridgeWait.swift
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
