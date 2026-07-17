import WidgetKit
import SwiftUI
import AtlasCore

// Body stack — peel de AtlasWidgetAccessories+Fleet+Body.

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyStack(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            fleetHeader(stale: stale, age: snapshot.ageText(at: entry.date))
            fleetState(snapshot)
            fleetDeliveryCaption(snapshot)
            Spacer(minLength: 0)
        }
    }
}
