import AtlasCore
import Foundation

// Spoken label — peel de FleetWidgetA11y.

extension FleetWidgetA11y {
    static func spokenLabel(snapshot: AtlasNativeSnapshot, stale: Bool, at date: Date, age: String) -> String {
        var parts = ["Frota"]
        if let line = incidentLine(snapshot.fleet?.incident) {
            parts.append(line)
        } else if snapshot.fleet?.incident?.present == true {
            parts.append("atenção na frota")
        } else if let scanned = snapshot.fleet?.scannedAt.flatMap(AtlasTime.date) {
            parts.append("frota íntegra, varrida \(scanned.relativeShort(to: date))")
        } else {
            parts.append("frota não lida")
        }
        if let delivery = snapshot.fleet?.lastDelivery, let caption = deliveryCaption(delivery) {
            parts.append(caption)
        }
        if stale { parts.append("visto \(age)") }
        return parts.joined(separator: ", ")
    }
}
