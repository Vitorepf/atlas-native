import AtlasCore
import Foundation

// Spoken label — peel de FleetWidgetA11y.
// Incident → AtlasWidgetAccessories+Fleet+A11ySpoken+Incident.swift
// Delivery → AtlasWidgetAccessories+Fleet+A11ySpoken+Delivery.swift
// Stale → AtlasWidgetAccessories+Fleet+A11ySpoken+Stale.swift

extension FleetWidgetA11y {
    static func spokenLabel(snapshot: AtlasNativeSnapshot, stale: Bool, at date: Date, age: String) -> String {
        var parts = ["Frota"]
        parts.append(contentsOf: spokenIncidentParts(snapshot: snapshot, at: date))
        if let delivery = spokenDeliveryPart(snapshot: snapshot) {
            parts.append(delivery)
        }
        if let staleLine = spokenStaleSuffix(stale: stale, age: age) {
            parts.append(staleLine)
        }
        return parts.joined(separator: ", ")
    }
}
