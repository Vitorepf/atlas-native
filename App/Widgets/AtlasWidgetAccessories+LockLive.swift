import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Snapshot widget surfaces (lock accessory / live session)
// Circular → AtlasWidgetAccessories+LockCircular.swift

struct LockAccessorySnapshotView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.accessibilityReduceMotion) var reduceMotion
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

    var spokenLabel: String {
        guard let snapshot = entry.snapshot else { return "abra o Atlas para atualizar o snapshot" }
        return LockAccessoryA11y.spokenLabel(
            snapshot: snapshot,
            stale: snapshot.isStale(at: entry.date),
            age: snapshot.ageText(at: entry.date)
        )
    }
}
