import WidgetKit
import SwiftUI
import AtlasCore

// Corpo do fleet widget — peel de FleetWidgetView.
// Delivery → AtlasWidgetAccessories+Fleet+Delivery.swift
// A11y → AtlasWidgetAccessories+Fleet+A11yChrome.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetBody(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        fleetA11yChrome(
            VStack(alignment: .leading, spacing: 7) {
                fleetHeader(stale: stale, age: snapshot.ageText(at: entry.date))
                fleetState(snapshot)
                fleetDeliveryCaption(snapshot)
                Spacer(minLength: 0)
            },
            snapshot: snapshot,
            stale: stale
        )
    }
}
