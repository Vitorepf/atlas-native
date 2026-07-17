import AtlasCore
import Foundation

/// Incident recommended action — peel de LockAccessoryA11y+Incident.

enum LockAccessoryA11yIncidentAction {
    static func recommendedAction(_ incident: AtlasNativeSnapshot.Fleet.Incident) -> String? {
        guard let action = incident.recommendedAction?
            .trimmingCharacters(in: .whitespacesAndNewlines), !action.isEmpty else {
            return nil
        }
        return action
    }
}
