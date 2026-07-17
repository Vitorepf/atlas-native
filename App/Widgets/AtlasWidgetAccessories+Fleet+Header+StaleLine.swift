import WidgetKit
import SwiftUI
import AtlasCore

// Stale badge — peel de AtlasWidgetAccessories+Fleet+Header.
// Style → AtlasWidgetAccessories+Fleet+Header+StaleLine+Style.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetHeaderStaleLine(stale: Bool, age: String) -> some View {
        if stale {
            fleetStaleLineText(age: age)
        }
    }
}
