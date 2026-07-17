import WidgetKit
import SwiftUI
import AtlasCore

// Body stack — peel de AtlasWidgetAccessories+Fleet+Body.
// Header → AtlasWidgetAccessories+Fleet+Body+Stack+Header.swift
// State → AtlasWidgetAccessories+Fleet+Body+Stack+State.swift
// Delivery → AtlasWidgetAccessories+Fleet+Body+Stack+Delivery.swift
// Lead → AtlasWidgetAccessories+Fleet+Body+Stack+Lead.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyStack(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            fleetBodyLeadRows(snapshot: snapshot, stale: stale)
            fleetBodyDeliveryRow(snapshot)
            Spacer(minLength: 0)
        }
    }
}
