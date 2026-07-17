import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Fleet snapshot widget
// State → AtlasWidgetAccessories+Fleet+State.swift

struct FleetWidgetView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let entry: SnapshotEntry

    var body: some View {
        SnapshotContainer {
            guard let snapshot = entry.snapshot else {
                return AnyView(InstallPromptView())
            }
            let stale = snapshot.isStale(at: entry.date)
            return AnyView(VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("✦ Frota")
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                    Spacer()
                    if stale {
                        Text("visto \(snapshot.ageText(at: entry.date))")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Ink.alert)
                    }
                }
                fleetState(snapshot)
                if family != .systemSmall,
                   let delivery = snapshot.fleet?.lastDelivery,
                   let caption = FleetWidgetA11y.deliveryCaption(delivery) {
                    Text(caption)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Ink.ink2)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .id(FleetWidgetA11y.contentPhaseID(snapshot: snapshot, stale: stale))
            .transaction { transaction in
                if reduceMotion { transaction.disablesAnimations = true }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(FleetWidgetA11y.spokenLabel(
                snapshot: snapshot,
                stale: stale,
                at: entry.date,
                age: snapshot.ageText(at: entry.date)
            )))
        }
        .widgetURL(URL(string: "atlas://autonomos"))
    }
}
