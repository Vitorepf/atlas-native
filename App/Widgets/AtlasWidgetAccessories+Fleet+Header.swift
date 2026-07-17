import WidgetKit
import SwiftUI
import AtlasCore

// Header Frota widget — peel de FleetWidgetView.

extension FleetWidgetView {
    @ViewBuilder
    func fleetHeader(stale: Bool, age: String) -> some View {
        HStack {
            Text("✦ Frota")
                .font(.system(size: 14, weight: .semibold, design: .serif))
            Spacer()
            if stale {
                Text("visto \(age)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.alert)
            }
        }
    }
}
