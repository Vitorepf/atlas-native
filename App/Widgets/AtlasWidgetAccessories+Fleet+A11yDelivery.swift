import AtlasCore
import Foundation

/// Delivery caption spoken — peel de FleetWidgetA11y.

extension FleetWidgetA11y {
    static func deliveryCaption(_ delivery: AtlasNativeSnapshot.Fleet.LastDelivery) -> String? {
        let title = delivery.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !title.isEmpty { return "última entrega \(title)" }
        let hash = delivery.mergeHash.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !hash.isEmpty else { return nil }
        return "última entrega \(String(hash.prefix(7)))"
    }
}
