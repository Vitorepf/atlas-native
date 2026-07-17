import WidgetKit
import SwiftUI
import AtlasCore

// Incident present fallback — peel de Fleet+State+Incident.

extension FleetWidgetView {
    @ViewBuilder
    func fleetStateIncidentPresent(_ snapshot: AtlasNativeSnapshot) -> some View {
        if snapshot.fleet?.incident?.present == true {
            Text("atenção na frota")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.alert)
                .lineLimit(2)
        }
    }
}
