import WidgetKit
import SwiftUI
import AtlasCore

// Circular lock accessory — peel de LockLive.
// Gauge → AtlasWidgetAccessories+LockCircular+Gauge.swift

extension LockAccessorySnapshotView {
    func circular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let count = snapshot.liveSessions?.count ?? 0
        let attention = LockAccessoryA11y.hasAttention(snapshot)
        let incident = LockAccessoryA11y.incidentLine(snapshot.fleet?.incident) != nil
        return circularGauge(count: count, attention: attention, incident: incident)
    }
}
