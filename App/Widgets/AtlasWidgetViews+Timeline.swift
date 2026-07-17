import WidgetKit
import SwiftUI
import AtlasCore

// Timeline policy — peel de AtlasWidgetViews.

extension SnapshotProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
        let entry = SnapshotEntry(date: .now, snapshot: SnapshotProviderLoad.load())
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(30 * 60))))
    }
}
