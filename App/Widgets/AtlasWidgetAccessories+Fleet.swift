import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Fleet snapshot widget
// State → AtlasWidgetAccessories+Fleet+State.swift · Header → +Header.swift
// Body → AtlasWidgetAccessories+Fleet+Body.swift

struct FleetWidgetView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let entry: SnapshotEntry

    var body: some View {
        SnapshotContainer {
            guard let snapshot = entry.snapshot else {
                return AnyView(InstallPromptView())
            }
            let stale = snapshot.isStale(at: entry.date)
            return AnyView(fleetBody(snapshot: snapshot, stale: stale))
        }
        .widgetURL(URL(string: "atlas://autonomos"))
    }
}
