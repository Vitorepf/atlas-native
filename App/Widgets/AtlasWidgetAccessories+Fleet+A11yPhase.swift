import AtlasCore
import Foundation

/// Content phase ID — peel de FleetWidgetA11y.

extension FleetWidgetA11y {
    static func contentPhaseID(snapshot: AtlasNativeSnapshot, stale: Bool) -> String {
        let incident = incidentLine(snapshot.fleet?.incident) ?? ""
        let present = snapshot.fleet?.incident?.present == true ? "1" : "0"
        let scanned = snapshot.fleet?.scannedAt ?? ""
        let delivery = snapshot.fleet?.lastDelivery?.mergeHash ?? ""
        return "\(incident)|\(present)|\(scanned)|\(delivery)|\(stale)"
    }
}
