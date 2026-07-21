import WidgetKit
import SwiftUI
import AtlasCore

// IDLE-COMPRESS — snapshot provider + helpers + container.

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

enum SnapshotProviderLoad {
    static func load() -> AtlasNativeSnapshot? {
        guard let file = AtlasNativeSnapshotStore.appGroupFileURL() else { return nil }
        guard let data = try? Data(contentsOf: file) else { return nil }
        return try? JSONDecoder.atlasNativeSnapshotDecoder().decode(AtlasNativeSnapshot.self, from: data)
    }
}

extension AtlasNativeSnapshot {
    func isStale(at now: Date) -> Bool {
        now.timeIntervalSince(generatedAt) > 6 * 60 * 60
    }

    func ageText(at now: Date) -> String {
        generatedAt.relativeShort(to: now)
    }
}

extension Date {
    func relativeShort(to now: Date) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(self)))
        if seconds >= 86_400 { return "há \(seconds / 86_400)d" }
        if seconds >= 3_600 { return "há \(seconds / 3_600)h" }
        if seconds >= 60 { return "há \(seconds / 60)m" }
        return "agora"
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
