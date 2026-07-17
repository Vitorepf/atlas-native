import WidgetKit
import SwiftUI
import AtlasCore

// Fleet incident branch — peel de AtlasWidgetAccessories+Fleet+State.

extension FleetWidgetView {
    @ViewBuilder
    func fleetStateIncident(_ snapshot: AtlasNativeSnapshot) -> some View {
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
        }
    }
}
