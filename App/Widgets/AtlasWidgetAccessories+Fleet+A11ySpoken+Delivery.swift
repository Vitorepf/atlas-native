import AtlasCore
import Foundation

// Delivery branch — peel de FleetWidgetA11y spoken label.

extension FleetWidgetA11y {
    static func spokenDeliveryPart(snapshot: AtlasNativeSnapshot) -> String? {
        guard let delivery = snapshot.fleet?.lastDelivery,
              let caption = deliveryCaption(delivery) else { return nil }
        return caption
    }
}
