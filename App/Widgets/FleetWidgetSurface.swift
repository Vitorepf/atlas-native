import WidgetKit
import SwiftUI
import AtlasCore

// IDLE-COMPRESS — Fleet accessory widget fused

// MARK: - Types

enum FleetWidgetA11y {
    static func incidentLine(_ incident: AtlasNativeSnapshot.Fleet.Incident?) -> String? {
        LockAccessoryA11y.incidentLine(incident)
    }
}

// MARK: - A11y chrome

extension FleetWidgetView {
    func fleetA11yPhaseSpoken<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        fleetA11ySpokenLabel(content, snapshot: snapshot, stale: stale)
    }
}

extension FleetWidgetView {
    func fleetA11yPhaseTransaction<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        content
            .id(FleetWidgetA11y.contentPhaseID(snapshot: snapshot, stale: stale))
            .transaction { transaction in fleetA11yTransaction(&transaction) }
    }
}

extension FleetWidgetView {
    func fleetA11yPhaseBind<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        fleetA11yPhaseSpoken(
            fleetA11yPhaseTransaction(content, snapshot: snapshot, stale: stale),
            snapshot: snapshot,
            stale: stale
        )
    }
}

extension FleetWidgetView {
    func fleetA11ySpokenLabel<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(FleetWidgetA11y.spokenLabel(
                snapshot: snapshot,
                stale: stale,
                at: entry.date,
                age: snapshot.ageText(at: entry.date)
            ))
    }
}

extension FleetWidgetView {
    func fleetA11yChrome<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        stale: Bool
    ) -> some View {
        fleetA11yPhaseBind(content, snapshot: snapshot, stale: stale)
    }
}

// MARK: - A11y ids / spoken

extension FleetWidgetA11y {
    static func deliveryCaption(_ delivery: AtlasNativeSnapshot.Fleet.LastDelivery) -> String? {
        let title = delivery.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !title.isEmpty { return "última entrega \(title)" }
        let hash = delivery.mergeHash.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !hash.isEmpty else { return nil }
        return "última entrega \(String(hash.prefix(7)))"
    }
}

extension FleetWidgetA11y {
    static func contentPhaseID(snapshot: AtlasNativeSnapshot, stale: Bool) -> String {
        let incident = incidentLine(snapshot.fleet?.incident) ?? ""
        let present = snapshot.fleet?.incident?.present == true ? "1" : "0"
        let scanned = snapshot.fleet?.scannedAt ?? ""
        let delivery = snapshot.fleet?.lastDelivery?.mergeHash ?? ""
        return "\(incident)|\(present)|\(scanned)|\(delivery)|\(stale)"
    }
}

extension FleetWidgetA11y {
    static func spokenCoreParts(snapshot: AtlasNativeSnapshot, at date: Date) -> [String] {
        var parts = ["Frota"]
        parts.append(contentsOf: spokenIncidentParts(snapshot: snapshot, at: date))
        if let delivery = spokenDeliveryPart(snapshot: snapshot) {
            parts.append(delivery)
        }
        return parts
    }
}

extension FleetWidgetA11y {
    static func spokenDeliveryPart(snapshot: AtlasNativeSnapshot) -> String? {
        guard let delivery = snapshot.fleet?.lastDelivery,
              let caption = deliveryCaption(delivery) else { return nil }
        return caption
    }
}

extension FleetWidgetA11y {
    static func spokenIncidentPresentParts(snapshot: AtlasNativeSnapshot) -> [String]? {
        if let line = incidentLine(snapshot.fleet?.incident) {
            return [line]
        }
        if snapshot.fleet?.incident?.present == true {
            return ["atenção na frota"]
        }
        return nil
    }
}

extension FleetWidgetA11y {
    static func spokenIncidentParts(snapshot: AtlasNativeSnapshot, at date: Date) -> [String] {
        if let present = spokenIncidentPresentParts(snapshot: snapshot) { return present }
        if let scanned = snapshot.fleet?.scannedAt.flatMap(AtlasTime.date) {
            return ["frota íntegra, varrida \(scanned.relativeShort(to: date))"]
        }
        return ["frota não lida"]
    }
}

extension FleetWidgetA11y {
    static func spokenStaleSuffix(stale: Bool, age: String) -> String? {
        stale ? "visto \(age)" : nil
    }
}

extension FleetWidgetA11y {
    static func spokenLabel(snapshot: AtlasNativeSnapshot, stale: Bool, at date: Date, age: String) -> String {
        var parts = spokenCoreParts(snapshot: snapshot, at: date)
        if let staleLine = spokenStaleSuffix(stale: stale, age: age) {
            parts.append(staleLine)
        }
        return parts.joined(separator: ", ")
    }
}

extension FleetWidgetView {
    func fleetA11yTransaction(_ transaction: inout Transaction) {
        if reduceMotion { transaction.disablesAnimations = true }
    }
}

extension FleetWidgetView {
    @ViewBuilder
    // MARK: - Body rows

func fleetBodyDeliveryRow(_ snapshot: AtlasNativeSnapshot) -> some View {
        fleetDeliveryCaption(snapshot)
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyHeaderRow(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        fleetHeader(stale: stale, age: snapshot.ageText(at: entry.date))
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyLeadRows(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        fleetBodyHeaderRow(snapshot: snapshot, stale: stale)
        fleetBodyStateRow(snapshot)
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyStateRow(_ snapshot: AtlasNativeSnapshot) -> some View {
        fleetState(snapshot)
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyStack(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            fleetBodyLeadRows(snapshot: snapshot, stale: stale)
            fleetBodyDeliveryRow(snapshot)
            Spacer(minLength: 0)
        }
    }
}

extension FleetWidgetView {
    @ViewBuilder
    // MARK: - Body shell

func fleetBody(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        fleetA11yChrome(
            fleetBodyStack(snapshot: snapshot, stale: stale),
            snapshot: snapshot,
            stale: stale
        )
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetBodyGate(snapshot: AtlasNativeSnapshot?, at date: Date) -> some View {
        if let snapshot {
            fleetBody(snapshot: snapshot, stale: snapshot.isStale(at: date))
        } else {
            InstallPromptView()
        }
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetDeliveryCaption(_ snapshot: AtlasNativeSnapshot) -> some View {
        if family != .systemSmall,
           let delivery = snapshot.fleet?.lastDelivery,
           let caption = FleetWidgetA11y.deliveryCaption(delivery) {
            Text(caption)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Ink.ink2)
                .lineLimit(1)
        }
    }
}

extension FleetWidgetView {
    func fleetStaleLineText(age: String) -> some View {
        Text("visto \(age)")
            .font(.system(size: 10, weight: .semibold, design: .monospaced))
            .foregroundStyle(Ink.alert)
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetHeaderStaleLine(stale: Bool, age: String) -> some View {
        if stale {
            fleetStaleLineText(age: age)
        }
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetHeader(stale: Bool, age: String) -> some View {
        HStack {
            Text("✦ Frota")
                .font(.system(size: 14, weight: .semibold, design: .serif))
            Spacer()
            fleetHeaderStaleLine(stale: stale, age: age)
        }
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetHealthyScanned(_ snapshot: AtlasNativeSnapshot, scanned: Date) -> some View {
        Text("frota íntegra")
            .font(.system(size: 18, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.healed)
        Text("varrida \(scanned.relativeShort(to: entry.date))")
            .font(.system(size: 12, design: .serif))
            .foregroundStyle(Ink.ink2)
    }
}

extension FleetWidgetView {
    var fleetHealthyUnread: some View {
        Text("frota não lida")
            .font(.system(size: 18, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.ink2)
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetHealthyOrUnread(_ snapshot: AtlasNativeSnapshot) -> some View {
        if let scanned = snapshot.fleet?.scannedAt.flatMap(AtlasTime.date) {
            fleetHealthyScanned(snapshot, scanned: scanned)
        } else {
            fleetHealthyUnread
        }
    }
}

extension FleetWidgetView {
    func fleetStateIncidentLineText(_ line: String) -> some View {
        Text(line)
            .font(.system(size: 16, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.alert)
            .lineLimit(2)
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetStateIncidentPresent(_ snapshot: AtlasNativeSnapshot) -> some View {
        if snapshot.fleet?.incident?.present == true {
            Text("atenção na frota")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.alert)
                .lineLimit(2)
        }
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetStateIncident(_ snapshot: AtlasNativeSnapshot) -> some View {
        if let line = FleetWidgetA11y.incidentLine(snapshot.fleet?.incident) {
            fleetStateIncidentLineText(line)
        } else {
            fleetStateIncidentPresent(snapshot)
        }
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetState(_ snapshot: AtlasNativeSnapshot) -> some View {
        if snapshot.fleet?.incident?.present == true || FleetWidgetA11y.incidentLine(snapshot.fleet?.incident) != nil {
            fleetStateIncident(snapshot)
        } else {
            fleetHealthyOrUnread(snapshot)
        }
    }
}

struct FleetWidgetView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let entry: SnapshotEntry

    // MARK: - Body

    var body: some View {
        SnapshotContainer {
            fleetBodyGate(snapshot: entry.snapshot, at: entry.date)
        }
        .widgetURL(URL(string: "atlas://autonomos"))
    }
}
