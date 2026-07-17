import WidgetKit
import SwiftUI
import AtlasCore

// Definições dos widgets de snapshot — peel de AtlasWidgets.
// CodeWeek → AtlasWidgets+CodeWeek.swift
// Lock/Live → AtlasWidgets+LockLiveDefinitions.swift

struct AtlasFleetWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "atlas.fleet.snapshot", provider: SnapshotProvider()) { entry in
            FleetWidgetView(entry: entry)
        }
        .configurationDisplayName("Atlas · Frota")
        .description("Estado da frota por exceção, lendo só o snapshot local.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
