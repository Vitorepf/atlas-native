import WidgetKit
import SwiftUI
import AtlasCore

// Header Frota widget — peel de FleetWidgetView.
// StaleLine → AtlasWidgetAccessories+Fleet+Header+StaleLine.swift

extension FleetWidgetView {
    @ViewBuilder
    func fleetHeader(stale: Bool, age: String) -> some View {
        HStack {
            Text("✦ Frota")
                .font(.system(size: 14, weight: .semibold, design: .serif))
            Spacer()
            fleetHeaderStaleLine(stale: stale, age: age)
        }
    }
}
