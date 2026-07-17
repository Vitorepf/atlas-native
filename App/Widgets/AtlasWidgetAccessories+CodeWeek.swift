import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Code week snapshot widget
// Body → AtlasWidgetAccessories+CodeWeek+Body.swift
// Unpublished → AtlasWidgetAccessories+CodeWeek+Unpublished.swift

struct CodeWeekWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: SnapshotEntry

    var body: some View {
        SnapshotContainer {
            AnyView(codeWeekEntryView(snapshot: entry.snapshot))
        }
        .widgetURL(URL(string: "atlas://code"))
    }
}
