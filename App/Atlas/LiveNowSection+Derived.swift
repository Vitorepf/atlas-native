import Foundation
import AtlasCore

// Derived session metrics — peel de LiveNowSection.

extension LiveNowSection {
    var sessions: [LiveSessionSnapshot] {
        Self.merged(local: localSessions, remote: remoteSessions)
    }

    var isHub: Bool { sessions.count >= 2 }

    var remoteCount: Int { sessions.filter(\.isRemote).count }
}
