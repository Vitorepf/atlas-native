import WidgetKit
import SwiftUI
import AtlasCore

// Estado da frota no widget — peel de FleetWidgetView.
// Healthy → AtlasWidgetAccessories+Fleet+Healthy.swift
// Incident → AtlasWidgetAccessories+Fleet+State+Incident.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetState(_ snapshot: AtlasNativeSnapshot) -> some View {
        if snapshot.fleet?.incident?.present == true || FleetWidgetA11y.incidentLine(snapshot.fleet?.incident) != nil {
            fleetStateIncident(snapshot)
        } else {
            fleetHealthyOrUnread(snapshot)
        }
    }
}
