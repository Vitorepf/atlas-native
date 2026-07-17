import AtlasCore
import Foundation

/// Incident flag fallback — peel de LockAccessoryA11y+Incident.

enum LockAccessoryA11yIncidentFlag {
    static func firstFlag(_ incident: AtlasNativeSnapshot.Fleet.Incident) -> String? {
        incident.flags.lazy
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .first(where: { !$0.isEmpty })
    }
}
