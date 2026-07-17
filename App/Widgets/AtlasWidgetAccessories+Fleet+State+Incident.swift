import WidgetKit
import SwiftUI
import AtlasCore

// Fleet incident branch — peel de AtlasWidgetAccessories+Fleet+State.
// Line → AtlasWidgetAccessories+Fleet+State+Incident+Line.swift
// Present → AtlasWidgetAccessories+Fleet+State+Incident+Present.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetStateIncident(_ snapshot: AtlasNativeSnapshot) -> some View {
        if let line = FleetWidgetA11y.incidentLine(snapshot.fleet?.incident) {
            fleetStateIncidentLineText(line)
        } else {
            fleetStateIncidentPresent(snapshot)
        }
    }
}
