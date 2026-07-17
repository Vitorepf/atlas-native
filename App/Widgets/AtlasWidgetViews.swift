import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Snapshot provider (SD-1)
// Age helpers → AtlasWidgetViews+Age.swift
// Container → AtlasWidgetViews+Container.swift
// Install → AtlasWidgetViews+Install.swift
// Load → AtlasWidgetViews+Load.swift
// GetSnapshot → AtlasWidgetViews+SnapshotProvider+GetSnapshot.swift

struct SnapshotEntry: TimelineEntry {
    let date: Date
    let snapshot: AtlasNativeSnapshot?
}

struct SnapshotProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnapshotEntry {
        SnapshotEntry(date: .now, snapshot: nil)
    }
}
