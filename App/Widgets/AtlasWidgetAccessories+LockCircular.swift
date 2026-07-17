import WidgetKit
import SwiftUI
import AtlasCore

// Circular lock accessory — peel de LockLive.

extension LockAccessorySnapshotView {
    func circular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let count = snapshot.liveSessions?.count ?? 0
        let attention = LockAccessoryA11y.hasAttention(snapshot)
        let incident = LockAccessoryA11y.incidentLine(snapshot.fleet?.incident) != nil
        return Gauge(value: Double(min(count, 5)), in: 0...5) {
            Text(incident ? "!" : (attention ? "‖" : "◆"))
        } currentValueLabel: {
            Text(incident ? "!" : "\(count)")
                .foregroundStyle(incident || attention ? Ink.alert : Ink.ink)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(incident || attention ? Ink.alert : Ink.gold)
        .transaction { transaction in
            if reduceMotion { transaction.disablesAnimations = true }
        }
    }
}
