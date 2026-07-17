import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Fleet snapshot widget

struct FleetWidgetView: View {
    @Environment(\.widgetFamily) private var family
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
                if family != .systemSmall, let delivery = snapshot.fleet?.lastDelivery {
                    Text("última entrega \(delivery.mergeHash.prefix(7))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Ink.ink2)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            })
        }
        .widgetURL(URL(string: "atlas://autonomos"))
    }

    @ViewBuilder
    private func fleetState(_ snapshot: AtlasNativeSnapshot) -> some View {
        if let incident = snapshot.fleet?.incident, incident.present {
            Text(incident.recommendedAction ?? incident.flags.first ?? "incidente na frota")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.alert)
                .lineLimit(2)
        } else if let scanned = snapshot.fleet?.scannedAt.flatMap(AtlasTime.date) {
            Text("frota íntegra")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.healed)
            Text("varrida \(scanned.relativeShort(to: entry.date))")
                .font(.system(size: 12, design: .serif))
                .foregroundStyle(Ink.ink2)
        } else {
            Text("frota não lida")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink2)
        }
    }
}
