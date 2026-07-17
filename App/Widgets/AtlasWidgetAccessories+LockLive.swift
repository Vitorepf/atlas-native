import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Snapshot widget surfaces (lock accessory / live session)

struct LockAccessorySnapshotView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let entry: SnapshotEntry

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                switch family {
                case .accessoryCircular:
                    circular(snapshot)
                case .accessoryInline:
                    Text(LockAccessoryA11y.inlineText(snapshot))
                        .foregroundStyle(emphasisColor(snapshot))
                default:
                    rectangular(snapshot)
                }
            } else {
                Text("abra o Atlas")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenLabel)
    }

    private var spokenLabel: String {
        guard let snapshot = entry.snapshot else { return "abra o Atlas para atualizar o snapshot" }
        return LockAccessoryA11y.spokenLabel(
            snapshot: snapshot,
            stale: snapshot.isStale(at: entry.date),
            age: snapshot.ageText(at: entry.date)
        )
    }

    private func circular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let count = snapshot.liveSessions?.count ?? 0
        let attention = LockAccessoryA11y.hasAttention(snapshot)
        let incident = LockAccessoryA11y.incidentLine(snapshot.fleet?.incident) != nil
        return Gauge(value: Double(min(count, 5)), in: 0...5) {
            Text(incident ? "!" : (attention ? "‖" : "◆"))
        } currentValueLabel: {
            Text(incident ? "!" : "\(count)")
                .foregroundStyle(incident || attention ? Ink.alert : Ink.ink)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(incident || attention ? Ink.alert : Ink.gold)
        .transaction { transaction in
            if reduceMotion { transaction.disablesAnimations = true }
        }
    }
}
