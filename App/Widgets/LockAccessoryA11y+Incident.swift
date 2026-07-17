import AtlasCore
import Foundation

/// Incident line — peel de LockAccessoryA11y.
/// Action → LockAccessoryA11y+Incident+Action.swift
/// Flag → LockAccessoryA11y+Incident+Flag.swift

enum LockAccessoryA11yIncident {
    /// Só texto publicado pelo Core — nunca «incidente na frota» fabricado.
    static func incidentLine(_ incident: AtlasNativeSnapshot.Fleet.Incident?) -> String? {
        guard let incident, incident.present else { return nil }
        return LockAccessoryA11yIncidentAction.recommendedAction(incident)
            ?? LockAccessoryA11yIncidentFlag.firstFlag(incident)
    }
}
