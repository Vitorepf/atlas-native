import WidgetKit
import SwiftUI
import AtlasCore

// Stale typography — peel de AtlasWidgetAccessories+Fleet+Header+StaleLine.

extension FleetWidgetView {
    func fleetStaleLineText(age: String) -> some View {
        Text("visto \(age)")
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundStyle(Ink.alert)
    }
}
