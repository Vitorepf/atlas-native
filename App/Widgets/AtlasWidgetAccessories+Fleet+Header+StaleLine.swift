import WidgetKit
import SwiftUI
import AtlasCore

// Stale badge — peel de AtlasWidgetAccessories+Fleet+Header.

extension FleetWidgetView {
    @ViewBuilder
    func fleetHeaderStaleLine(stale: Bool, age: String) -> some View {
        if stale {
            Text("visto \(age)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        }
    }
}
