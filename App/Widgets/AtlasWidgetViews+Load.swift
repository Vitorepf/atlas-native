import WidgetKit
import SwiftUI
import AtlasCore

// Snapshot load — peel de AtlasWidgetViews.

enum SnapshotProviderLoad {
    static func load() -> AtlasNativeSnapshot? {
        guard let file = AtlasNativeSnapshotStore.appGroupFileURL() else { return nil }
        guard let data = try? Data(contentsOf: file) else { return nil }
        return try? JSONDecoder.atlasNativeSnapshotDecoder().decode(AtlasNativeSnapshot.self, from: data)
    }
}
