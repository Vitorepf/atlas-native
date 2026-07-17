import AtlasCore
import Foundation

// Spoken branch lines — peel de AtlasWidgetAccessories+LockLive+Spoken.
// Alert → AtlasWidgetAccessories+LockLive+Spoken+Branch+Alert.swift

extension LockAccessoryA11y {
    static func spokenLabelBranchLines(snapshot: AtlasNativeSnapshot) -> [String] {
        if let alert = spokenLabelAlertLines(snapshot: snapshot) { return alert }
        if let sessions = snapshot.liveSessions, !sessions.isEmpty {
            return spokenLiveSessions(sessions)
        }
        return ["silêncio na obra"]
    }
}
