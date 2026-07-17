import AtlasCore
import Foundation

// Incident present spoken — peel de Fleet A11ySpoken Incident.

extension FleetWidgetA11y {
    static func spokenIncidentPresentParts(snapshot: AtlasNativeSnapshot) -> [String]? {
        if let line = incidentLine(snapshot.fleet?.incident) {
            return [line]
        }
        if snapshot.fleet?.incident?.present == true {
            return ["atenção na frota"]
        }
        return nil
    }
}
