import AtlasCore
import Foundation

/// Spoken label do lock — peel de LockAccessoryA11y.
/// Sessions → AtlasWidgetAccessories+LockLive+SpokenSessions.swift
/// Attention → AtlasWidgetAccessories+LockLive+Spoken+Attention.swift

extension LockAccessoryA11y {
    static func spokenLabel(snapshot: AtlasNativeSnapshot, stale: Bool, age: String) -> String {
        var parts: [String] = ["Atlas lock"]
        if let line = incidentLine(snapshot.fleet?.incident) {
            parts.append("frota, \(line)")
        } else if let attention = spokenAttentionLine(snapshot) {
            parts.append(attention)
        } else if let sessions = snapshot.liveSessions, !sessions.isEmpty {
            parts.append(contentsOf: spokenLiveSessions(sessions))
        } else {
            parts.append("silêncio na obra")
        }
        if stale { parts.append("visto \(age)") }
        return parts.joined(separator: ", ")
    }
}
