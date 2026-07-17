import WidgetKit
import SwiftUI
import AtlasCore

// Estado da frota no widget — peel de FleetWidgetView.

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
        } else if let scanned = snapshot.fleet?.scannedAt.flatMap(AtlasTime.date) {
            Text("frota íntegra")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.healed)
            Text("varrida \(scanned.relativeShort(to: entry.date))")
                .font(.system(size: 12, design: .serif))
                .foregroundStyle(Ink.ink2)
        } else {
            Text("frota não lida")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink2)
        }
    }
}
