import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Snapshot provider + shared container (SD-1)
// Age helpers → AtlasWidgetViews+Age.swift

struct SnapshotEntry: TimelineEntry {
    let date: Date
    let snapshot: AtlasNativeSnapshot?
}

struct SnapshotProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnapshotEntry {
        SnapshotEntry(date: .now, snapshot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
        completion(SnapshotEntry(date: .now, snapshot: Self.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
        let entry = SnapshotEntry(date: .now, snapshot: Self.load())
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(30 * 60))))
    }

    private static func load() -> AtlasNativeSnapshot? {
        guard let file = AtlasNativeSnapshotStore.appGroupFileURL() else { return nil }
        guard let data = try? Data(contentsOf: file) else { return nil }
        return try? JSONDecoder.atlasNativeSnapshotDecoder().decode(AtlasNativeSnapshot.self, from: data)
    }
}

struct SnapshotContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            Ink.bg
            content()
                .foregroundStyle(Ink.ink)
                .padding(14)
        }
        .containerBackground(Ink.bg, for: .widget)
    }
}

struct InstallPromptView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("✦ Atlas")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.gold)
            Text("abra o Atlas")
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink)
        }
    }
}
