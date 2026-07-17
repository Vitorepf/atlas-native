import WidgetKit
import SwiftUI
import AtlasCore

// Delivery caption — peel de Fleet+Body.

extension FleetWidgetView {
    @ViewBuilder
    func fleetDeliveryCaption(_ snapshot: AtlasNativeSnapshot) -> some View {
        if family != .systemSmall,
           let delivery = snapshot.fleet?.lastDelivery,
           let caption = FleetWidgetA11y.deliveryCaption(delivery) {
            Text(caption)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Ink.ink2)
                .lineLimit(1)
        }
    }
}
