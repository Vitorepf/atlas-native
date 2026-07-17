import WidgetKit
import SwiftUI
import AtlasCore

// Corpo do fleet widget — peel de FleetWidgetView.
// Stack → AtlasWidgetAccessories+Fleet+Body+Stack.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetBody(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        fleetA11yChrome(
            fleetBodyStack(snapshot: snapshot, stale: stale),
            snapshot: snapshot,
            stale: stale
        )
    }
}
