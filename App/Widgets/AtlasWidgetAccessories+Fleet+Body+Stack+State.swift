import WidgetKit
import SwiftUI
import AtlasCore

// Fleet state row — peel de AtlasWidgetAccessories+Fleet+Body+Stack.

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyStateRow(_ snapshot: AtlasNativeSnapshot) -> some View {
        fleetState(snapshot)
    }
}
