import AtlasCore
import Foundation

// Lock spoken incident/attention — peel de LockLive Spoken Branch.

extension LockAccessoryA11y {
    static func spokenLabelAlertLines(snapshot: AtlasNativeSnapshot) -> [String]? {
        if let line = incidentLine(snapshot.fleet?.incident) {
            return ["frota, \(line)"]
        }
        if let attention = spokenAttentionLine(snapshot) {
            return [attention]
        }
        return nil
    }
}
