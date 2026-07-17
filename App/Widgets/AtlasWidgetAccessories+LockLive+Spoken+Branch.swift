import AtlasCore
import Foundation

// Spoken branch lines — peel de AtlasWidgetAccessories+LockLive+Spoken.

extension LockAccessoryA11y {
    static func spokenLabelBranchLines(snapshot: AtlasNativeSnapshot) -> [String] {
        if let line = incidentLine(snapshot.fleet?.incident) {
            return ["frota, \(line)"]
        }
        if let attention = spokenAttentionLine(snapshot) {
            return [attention]
        }
        if let sessions = snapshot.liveSessions, !sessions.isEmpty {
            return spokenLiveSessions(sessions)
        }
        return ["silêncio na obra"]
    }
}
