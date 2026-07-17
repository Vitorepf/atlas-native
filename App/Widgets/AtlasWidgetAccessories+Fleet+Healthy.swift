import WidgetKit
import SwiftUI
import AtlasCore

// Fleet healthy/unread state — peel de AtlasWidgetAccessories+Fleet+State.

extension FleetWidgetView {
    @ViewBuilder
    func fleetHealthyOrUnread(_ snapshot: AtlasNativeSnapshot) -> some View {
        if let scanned = snapshot.fleet?.scannedAt.flatMap(AtlasTime.date) {
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
