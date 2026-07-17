import WidgetKit
import SwiftUI
import AtlasCore

// getSnapshot — peel de AtlasWidgetViews.

extension SnapshotProvider {
    func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
        completion(SnapshotEntry(date: .now, snapshot: SnapshotProviderLoad.load()))
    }
}
