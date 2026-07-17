import AtlasCore
import Foundation

// Fleet spoken core — peel de FleetWidgetA11y spokenLabel.

extension FleetWidgetA11y {
    static func spokenCoreParts(snapshot: AtlasNativeSnapshot, at date: Date) -> [String] {
        var parts = ["Frota"]
        parts.append(contentsOf: spokenIncidentParts(snapshot: snapshot, at: date))
        if let delivery = spokenDeliveryPart(snapshot: snapshot) {
            parts.append(delivery)
        }
        return parts
    }
}
