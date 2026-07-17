import WidgetKit
import SwiftUI
import AtlasCore

// Fleet header row — peel de AtlasWidgetAccessories+Fleet+Body+Stack.
// State → AtlasWidgetAccessories+Fleet+Body+Stack+State.swift
// Delivery → AtlasWidgetAccessories+Fleet+Body+Stack+Delivery.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyHeaderRow(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        fleetHeader(stale: stale, age: snapshot.ageText(at: entry.date))
    }
}
