import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Fleet snapshot widget
// State → AtlasWidgetAccessories+Fleet+State.swift · Header → +Header.swift
// Body → AtlasWidgetAccessories+Fleet+Body.swift · Gate → +Fleet+BodyGate.swift

struct FleetWidgetView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let entry: SnapshotEntry

    var body: some View {
        SnapshotContainer {
            fleetBodyGate(snapshot: entry.snapshot, at: entry.date)
        }
        .widgetURL(URL(string: "atlas://autonomos"))
    }
}
