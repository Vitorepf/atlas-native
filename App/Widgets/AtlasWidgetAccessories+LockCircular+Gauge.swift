import WidgetKit
import SwiftUI
import AtlasCore

// Circular gauge — peel de AtlasWidgetAccessories+LockCircular.
// Symbol → AtlasWidgetAccessories+LockCircular+Gauge+Symbol.swift

extension LockAccessorySnapshotView {
    func circularGauge(count: Int, attention: Bool, incident: Bool) -> some View {
        Gauge(value: Double(min(count, 5)), in: 0...5) {
            Text(circularGaugeSymbol(incident: incident, attention: attention))
        } currentValueLabel: {
            Text(circularGaugeValueLabel(count: count, incident: incident))
                .foregroundStyle(incident || attention ? Ink.alert : Ink.ink)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(incident || attention ? Ink.alert : Ink.gold)
        .transaction { transaction in
            if reduceMotion { transaction.disablesAnimations = true }
        }
    }
}
