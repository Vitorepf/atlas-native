import AtlasCore
import Foundation

// Incident branch — peel de FleetWidgetA11y spoken label.
// Present → AtlasWidgetAccessories+Fleet+A11ySpoken+Incident+Present.swift

extension FleetWidgetA11y {
    static func spokenIncidentParts(snapshot: AtlasNativeSnapshot, at date: Date) -> [String] {
        if let present = spokenIncidentPresentParts(snapshot: snapshot) { return present }
        if let scanned = snapshot.fleet?.scannedAt.flatMap(AtlasTime.date) {
            return ["frota íntegra, varrida \(scanned.relativeShort(to: date))"]
        }
        return ["frota não lida"]
    }
}
