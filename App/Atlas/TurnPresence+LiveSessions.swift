import SwiftUI
import AtlasCore

// LiveSessionSnapshot + publishLiveSessions — peel de TurnPresence.

// LiveSessionSnapshot → LiveSessionSnapshot.swift

@MainActor
extension TurnPresence {
    /// Reconstrói `liveSessions` a partir das entries ongoing. Dedup por
    /// traceId; conversa nova sem thread canônica fica sem navegação.
    func publishLiveSessions() {
        var byTrace: [String: LiveSessionSnapshot] = [:]
        for entry in entries.values where entry.ongoing {
            guard let snap = liveSessionSnapshot(from: entry) else { continue }
            byTrace[snap.id] = snap
        }
        liveSessions = byTrace.values.sorted { $0.startedAt < $1.startedAt }
    }
}
