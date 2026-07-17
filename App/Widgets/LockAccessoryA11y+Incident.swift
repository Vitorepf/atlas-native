import AtlasCore
import Foundation

/// Incident line — peel de LockAccessoryA11y.

enum LockAccessoryA11yIncident {
    /// Só texto publicado pelo Core — nunca «incidente na frota» fabricado.
    static func incidentLine(_ incident: AtlasNativeSnapshot.Fleet.Incident?) -> String? {
        guard let incident, incident.present else { return nil }
        if let action = incident.recommendedAction?
            .trimmingCharacters(in: .whitespacesAndNewlines), !action.isEmpty {
            return action
        }
        if let flag = incident.flags.lazy
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .first(where: { !$0.isEmpty }) {
            return flag
        }
        return nil
    }
}
