import WidgetKit
import SwiftUI
import AtlasCore

// Corpo do fleet widget — peel de FleetWidgetView.
// Delivery → AtlasWidgetAccessories+Fleet+Delivery.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetBody(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            fleetHeader(stale: stale, age: snapshot.ageText(at: entry.date))
            fleetState(snapshot)
            fleetDeliveryCaption(snapshot)
            Spacer(minLength: 0)
        }
        .id(FleetWidgetA11y.contentPhaseID(snapshot: snapshot, stale: stale))
        .transaction { transaction in
            if reduceMotion { transaction.disablesAnimations = true }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(FleetWidgetA11y.spokenLabel(
            snapshot: snapshot,
            stale: stale,
            at: entry.date,
            age: snapshot.ageText(at: entry.date)
        ))
    }
}
