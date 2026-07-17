import AtlasCore
import Foundation

/// Spoken labels do widget Frota — peel de FleetWidgetView (CICLO C residual).
/// Spoken → AtlasWidgetAccessories+Fleet+A11ySpoken.swift

enum FleetWidgetA11y {
    static func incidentLine(_ incident: AtlasNativeSnapshot.Fleet.Incident?) -> String? {
        LockAccessoryA11y.incidentLine(incident)
    }

    static func deliveryCaption(_ delivery: AtlasNativeSnapshot.Fleet.LastDelivery) -> String? {
        let title = delivery.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !title.isEmpty { return "última entrega \(title)" }
        let hash = delivery.mergeHash.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !hash.isEmpty else { return nil }
        return "última entrega \(String(hash.prefix(7)))"
    }

    static func contentPhaseID(snapshot: AtlasNativeSnapshot, stale: Bool) -> String {
        let incident = incidentLine(snapshot.fleet?.incident) ?? ""
        let present = snapshot.fleet?.incident?.present == true ? "1" : "0"
        let scanned = snapshot.fleet?.scannedAt ?? ""
        let delivery = snapshot.fleet?.lastDelivery?.mergeHash ?? ""
        return "\(incident)|\(present)|\(scanned)|\(delivery)|\(stale)"
    }
}
