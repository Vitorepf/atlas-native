import Foundation
import AtlasCore

/// Live session projection — peel de AtlasNativeSnapshotWriter+Projection.

extension AtlasNativeSnapshotWriter {
    static func liveSessions(from sessions: [LiveSessionSnapshot]) -> [AtlasNativeSnapshot.LiveSession]? {
        let projected = sessions.map { session in
            AtlasNativeSnapshot.LiveSession(
                title: session.title,
                phaseTitle: session.phaseTitle,
                timing: timing(from: session.timing),
                elapsedActiveMs: session.elapsedActiveMs,
                runningSince: session.runningSince.map(iso)
            )
        }
        return projected.isEmpty ? [] : projected
    }

    static func timing(from timing: AtlasExecutionPresence.Timing) -> AtlasNativeSnapshot.LiveSession.Timing {
        switch timing {
        case .running: return .running
        case .paused: return .paused
        case .finished: return .finished
        }
    }
}
