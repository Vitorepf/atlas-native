import WidgetKit
import SwiftUI
import AtlasCore

// Fleet scanned state — peel de AtlasWidgetAccessories+Fleet+Healthy.

extension FleetWidgetView {
    @ViewBuilder
    func fleetHealthyScanned(_ snapshot: AtlasNativeSnapshot, scanned: Date) -> some View {
        Text("frota íntegra")
            .font(.system(size: 18, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.healed)
        Text("varrida \(scanned.relativeShort(to: entry.date))")
            .font(.system(size: 12, design: .serif))
            .foregroundStyle(Ink.ink2)
    }
}
