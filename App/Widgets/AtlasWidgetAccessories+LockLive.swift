import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Snapshot widget surfaces (lock accessory / live session)

struct LockAccessorySnapshotView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SnapshotEntry

    var body: some View {
        if let snapshot = entry.snapshot {
            switch family {
            case .accessoryCircular:
                circular(snapshot)
            case .accessoryInline:
                Text(inlineText(snapshot))
                    .foregroundStyle(emphasisColor(snapshot))
            default:
                rectangular(snapshot)
            }
        } else {
            Text("abra o Atlas")
        }
    }

    private func circular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let count = snapshot.liveSessions?.count ?? 0
        let attention = hasAttention(snapshot)
        let incident = snapshot.fleet?.incident?.present == true
        return Gauge(value: Double(min(count, 5)), in: 0...5) {
            Text(incident ? "!" : (attention ? "⚠" : "◆"))
        } currentValueLabel: {
            Text(incident ? "!" : "\(count)")
                .foregroundStyle(incident || attention ? Ink.alert : Ink.ink)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(incident || attention ? Ink.alert : Ink.gold)
    }
}
