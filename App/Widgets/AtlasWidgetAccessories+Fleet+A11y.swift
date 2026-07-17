import AtlasCore
import Foundation

/// Spoken labels do widget Frota — peel de FleetWidgetView (CICLO C residual).
/// Spoken → AtlasWidgetAccessories+Fleet+A11ySpoken.swift
/// Delivery → AtlasWidgetAccessories+Fleet+A11yDelivery.swift
/// Phase → AtlasWidgetAccessories+Fleet+A11yPhase.swift

enum FleetWidgetA11y {
    static func incidentLine(_ incident: AtlasNativeSnapshot.Fleet.Incident?) -> String? {
        LockAccessoryA11y.incidentLine(incident)
    }
}
