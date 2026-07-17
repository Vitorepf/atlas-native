import WidgetKit
import SwiftUI
import AtlasCore

// Body stack — peel de AtlasWidgetAccessories+Fleet+Body.
// Header → AtlasWidgetAccessories+Fleet+Body+Stack+Header.swift
// State → AtlasWidgetAccessories+Fleet+Body+Stack+State.swift
// Delivery → AtlasWidgetAccessories+Fleet+Body+Stack+Delivery.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyStack(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            fleetBodyHeaderRow(snapshot: snapshot, stale: stale)
            fleetBodyStateRow(snapshot)
            fleetBodyDeliveryRow(snapshot)
            Spacer(minLength: 0)
        }
    }
}
