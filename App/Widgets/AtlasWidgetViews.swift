import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Snapshot provider (SD-1)
// Age helpers → AtlasWidgetViews+Age.swift
// Container → AtlasWidgetViews+Container.swift
// Install → AtlasWidgetViews+Install.swift
// Load → AtlasWidgetViews+Load.swift

struct SnapshotEntry: TimelineEntry {
    let date: Date
    let snapshot: AtlasNativeSnapshot?
}

struct SnapshotProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnapshotEntry {
        SnapshotEntry(date: .now, snapshot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
        completion(SnapshotEntry(date: .now, snapshot: SnapshotProviderLoad.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
        let entry = SnapshotEntry(date: .now, snapshot: SnapshotProviderLoad.load())
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(30 * 60))))
    }
}
