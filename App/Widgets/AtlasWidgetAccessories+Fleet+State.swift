import WidgetKit
import SwiftUI
import AtlasCore

// Estado da frota no widget — peel de FleetWidgetView.
// Healthy → AtlasWidgetAccessories+Fleet+Healthy.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetState(_ snapshot: AtlasNativeSnapshot) -> some View {
        if let line = FleetWidgetA11y.incidentLine(snapshot.fleet?.incident) {
            Text(line)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.alert)
                .lineLimit(2)
        } else if snapshot.fleet?.incident?.present == true {
            Text("atenção na frota")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.alert)
                .lineLimit(2)
        } else {
            fleetHealthyOrUnread(snapshot)
        }
    }
}
