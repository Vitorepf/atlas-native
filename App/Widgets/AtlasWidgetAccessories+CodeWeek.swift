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
            guard let snapshot = entry.snapshot else {
                return AnyView(InstallPromptView())
            }
            guard let week = snapshot.week else {
                return AnyView(unpublishedWeek)
            }
            let stale = snapshot.isStale(at: entry.date)
            return AnyView(weekBody(week: week, stale: stale, age: snapshot.ageText(at: entry.date)))
        }
        .widgetURL(URL(string: "atlas://code"))
    }
}
