import WidgetKit
import SwiftUI
import AtlasCore

// Fleet delivery row — peel de AtlasWidgetAccessories+Fleet+Body+Stack.

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyDeliveryRow(_ snapshot: AtlasNativeSnapshot) -> some View {
        fleetDeliveryCaption(snapshot)
    }
}
