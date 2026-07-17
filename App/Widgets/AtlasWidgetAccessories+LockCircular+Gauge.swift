import WidgetKit
import SwiftUI
import AtlasCore

// Circular gauge — peel de AtlasWidgetAccessories+LockCircular.

extension LockAccessorySnapshotView {
    func circularGauge(count: Int, attention: Bool, incident: Bool) -> some View {
        Gauge(value: Double(min(count, 5)), in: 0...5) {
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
