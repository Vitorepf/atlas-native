import WidgetKit
import SwiftUI
import AtlasCore

// Gauge symbol — peel de AtlasWidgetAccessories+LockCircular+Gauge.

extension LockAccessorySnapshotView {
    func circularGaugeSymbol(incident: Bool, attention: Bool) -> String {
        incident ? "!" : (attention ? "‖" : "◆")
    }

    func circularGaugeValueLabel(count: Int, incident: Bool) -> String {
        incident ? "!" : "\(count)"
    }
}
