import WidgetKit
import SwiftUI
import AtlasCore

// Fleet unread state — peel de AtlasWidgetAccessories+Fleet+Healthy.

extension FleetWidgetView {
    var fleetHealthyUnread: some View {
        Text("frota não lida")
            .font(.system(size: 18, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.ink2)
    }
}
