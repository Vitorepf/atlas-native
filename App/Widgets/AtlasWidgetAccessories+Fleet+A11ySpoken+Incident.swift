import AtlasCore
import Foundation

// Incident branch — peel de FleetWidgetA11y spoken label.

extension FleetWidgetA11y {
    static func spokenIncidentParts(snapshot: AtlasNativeSnapshot, at date: Date) -> [String] {
        if let line = incidentLine(snapshot.fleet?.incident) {
            return [line]
        }
        if snapshot.fleet?.incident?.present == true {
            return ["atenção na frota"]
        }
        if let scanned = snapshot.fleet?.scannedAt.flatMap(AtlasTime.date) {
            return ["frota íntegra, varrida \(scanned.relativeShort(to: date))"]
        }
        return ["frota não lida"]
    }
}
