import SwiftUI
import WidgetKit
import AtlasCore
import ActivityKit

// GOD-RESTRUCTURE: Widgets surfaces fused A

// MARK: - LiveSessionWidgetSurface

// MARK: - Types

enum LiveSessionWidgetA11y {
    static let productFollow = "Seguir"
    static let productLiveSessionKicker = "✦ Sessão viva"
    static let productSilence = "silêncio na obra"
    static func productSeen(_ age: String) -> String { "visto \(age)" }

    static func spokenSilenceDetail(_ snapshot: AtlasNativeSnapshot) -> String {
        guard let delivery = snapshot.fleet?.lastDelivery else {
            return "nenhuma sessão viva agora"
        }
        let title = delivery.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !title.isEmpty { return "última concluída \(title)" }
        let hash = delivery.mergeHash.trimmingCharacters(in: .whitespacesAndNewlines)
        if !hash.isEmpty { return "última concluída \(String(hash.prefix(7)))" }
        return "nenhuma sessão viva agora"
    }
}

// MARK: - A11y chrome

extension LiveSessionWidgetView {
    func liveSessionA11yPhaseID<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        content.id(LiveSessionWidgetA11y.contentPhaseID(snapshot: snapshot, live: live, stale: stale))
    }
}

extension LiveSessionWidgetView {
    func liveSessionA11yPhaseBind<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        liveSessionSpokenLabelBind(
            liveSessionA11yPhaseID(content, snapshot: snapshot, live: live, stale: stale),
            snapshot: snapshot,
            live: live,
            stale: stale
        )
    }
}

extension LiveSessionWidgetView {
    func liveSessionA11yTransactionBind<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        liveSessionA11yPhaseBind(
            content.transaction { transaction in liveSessionA11yTransaction(&transaction) },
            snapshot: snapshot,
            live: live,
            stale: stale
        )
    }
}

extension LiveSessionWidgetView {
    func liveSessionA11yChrome<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        liveSessionA11yTransactionBind(content, snapshot: snapshot, live: live, stale: stale)
    }
}

// MARK: - A11y ids / spoken

extension LiveSessionWidgetA11y {
    static func contentPhaseID(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> String {
        let title = live?.title ?? ""
        let phase = live?.phaseTitle ?? ""
        let timing = live?.timing.rawValue ?? "none"
        let delivery = snapshot.fleet?.lastDelivery?.mergeHash ?? ""
        return "\(title)|\(phase)|\(timing)|\(delivery)|\(stale)"
    }
}

extension LiveSessionWidgetA11y {
    static func spokenCoreParts(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?
    ) -> [String] {
        if let live {
            return spokenLiveParts(live)
        }
        return spokenSilenceParts(snapshot)
    }
}

extension LiveSessionWidgetA11y {
    static func spokenSilenceParts(_ snapshot: AtlasNativeSnapshot) -> [String] {
        ["silêncio na obra", spokenSilenceDetail(snapshot)]
    }
}

extension LiveSessionWidgetA11y {
    static func spokenStaleParts(stale: Bool, age: String) -> [String] {
        stale ? ["visto \(age)"] : []
    }
}

extension LiveSessionWidgetA11y {
    static func spokenLabel(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool,
        age: String
    ) -> String {
        var parts = ["Sessão viva"]
        parts.append(contentsOf: spokenCoreParts(snapshot: snapshot, live: live))
        parts.append(contentsOf: spokenStaleParts(stale: stale, age: age))
        return parts.joined(separator: ", ")
    }
}

// MARK: - Spoken bind

extension LiveSessionWidgetView {
    func liveSessionSpokenCombine<Content: View>(_ content: Content) -> some View {
        content.accessibilityElement(children: .combine)
    }
}

extension LiveSessionWidgetView {
    func liveSessionSpokenLabelText(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> String {
        LiveSessionWidgetA11y.spokenLabel(
            snapshot: snapshot,
            live: live,
            stale: stale,
            age: snapshot.ageText(at: entry.date)
        )
    }
}

extension LiveSessionWidgetView {
    func liveSessionSpokenLabelBind<Content: View>(
        _ content: Content,
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?,
        stale: Bool
    ) -> some View {
        liveSessionSpokenCombine(content)
            .accessibilityLabel(
                liveSessionSpokenLabelText(snapshot: snapshot, live: live, stale: stale)
            )
    }
}

extension LiveSessionWidgetA11y {
    static func spokenLiveParts(_ live: AtlasNativeSnapshot.LiveSession) -> [String] {
        var parts = ["\(live.title), \(live.phaseTitle)"]
        if live.timing == .paused {
            parts.append("pausado")
            if let clock = LockAccessoryA11y.frozenClock(live) {
                parts.append("tempo congelado \(clock)")
            }
        } else {
            parts.append("em execução")
        }
        return parts
    }
}

extension LiveSessionWidgetView {
    func liveSessionA11yTransaction(_ transaction: inout Transaction) {
        if reduceMotion { transaction.disablesAnimations = true }
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    // MARK: - Body / timer

func liveSessionTimerBlock(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTimerRow(live)
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTimerRow(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        HStack {
            LiveSessionWidgetTimer(live: live)
            Spacer()
            liveSessionFollowChip
        }
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTitlesBlock(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTitles(live)
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionActiveBody(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTitlesBlock(live)
        liveSessionTimerBlock(live)
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    // MARK: - Content shell

func liveSessionContent(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?, stale: Bool) -> some View {
        liveSessionA11yChrome(
            liveSessionContentStack(snapshot: snapshot, live: live, stale: stale),
            snapshot: snapshot,
            live: live,
            stale: stale
        )
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionActiveBranch(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionActiveBody(live)
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentBranch(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?) -> some View {
        if let live {
            liveSessionActiveBranch(live)
        } else {
            liveSessionSilenceBranch(snapshot)
        }
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentHeader(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        liveSessionHeader(stale: stale, age: snapshot.ageText(at: entry.date))
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionSilenceBranch(_ snapshot: AtlasNativeSnapshot) -> some View {
        liveSessionSilenceBody(snapshot)
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentBranchRow(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?
    ) -> some View {
        liveSessionContentBranch(snapshot: snapshot, live: live)
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentHeaderRow(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        liveSessionContentHeader(snapshot: snapshot, stale: stale)
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentStack(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            liveSessionContentHeaderRow(snapshot: snapshot, stale: stale)
            liveSessionContentBranchRow(snapshot: snapshot, live: live)
        }
    }
}

extension LiveSessionWidgetView {
    var liveSessionFollowChip: some View {
        Text(LiveSessionWidgetA11y.productFollow)
            .font(.system(size: 12, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.bg)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Ink.gold))
            .accessibilityHidden(true)
    }
}

extension LiveSessionWidgetView {
    func liveSessionHeader(stale: Bool, age: String) -> some View {
        HStack {
            Text(LiveSessionWidgetA11y.productLiveSessionKicker)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .accessibilityHidden(true)
            Spacer()
            if stale {
                Text(LiveSessionWidgetA11y.productSeen(age))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Ink.alert)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionSilenceBody(_ snapshot: AtlasNativeSnapshot) -> some View {
        Text(LiveSessionWidgetA11y.productSilence)
            .font(.system(size: 17, weight: .semibold, design: .serif))
            .accessibilityHidden(true)
        Text(LiveSessionWidgetA11y.spokenSilenceDetail(snapshot))
            .font(.system(size: 12, design: .serif))
            .foregroundStyle(Ink.ink2)
            .accessibilityHidden(true)
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionInstallGate<Content: View>(
        snapshot: AtlasNativeSnapshot?,
        @ViewBuilder content: (AtlasNativeSnapshot) -> Content
    ) -> some View {
        if let snapshot {
            content(snapshot)
        } else {
            InstallPromptView()
        }
    }
}

extension LiveSessionWidgetView {
    func liveSessionSnapshotGate<Content: View>(
        @ViewBuilder content: @escaping (AtlasNativeSnapshot, AtlasNativeSnapshot.LiveSession?, Bool) -> Content
    ) -> some View {
        SnapshotContainer {
            liveSessionInstallGate(snapshot: entry.snapshot) { snapshot in
                let stale = snapshot.isStale(at: entry.date)
                let live = snapshot.liveSessions?.first
                content(snapshot, live, stale)
            }
        }
    }
}

extension LiveSessionWidgetTimer {
    @ViewBuilder
    var timerBranchBody: some View {
        if live.timing != .paused, let since = live.runningSince.flatMap(AtlasTime.date) {
            activeClock(since: since)
        } else {
            timerFallbackBody
        }
    }
}

extension LiveSessionWidgetTimer {
    @ViewBuilder
    func timerStyle<Content: View>(_ content: Content) -> some View {
        content
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
            .accessibilityHidden(true)
    }
}

// MARK: - FleetWidgetSurface

// MARK: - Types

enum FleetWidgetA11y {
    static let productFleetKicker = "✦ Frota"
    static let productFleetIntact = "frota íntegra"
    static let productFleetUnread = "frota não lida"
    static let productFleetAttention = "atenção na frota"
    static let productOpenAtlas = "abra o Atlas"
    static let productAtlasKicker = "✦ Atlas"
    static let productWeekKicker = "✦ Semana"
    static let productQuietWeek = "semana quieta · sem commits nem curas"
    static let productWeekUnpublished = "semana ainda não publicada"
    static let productDone = "concluído"
    static func productScanned(_ age: String) -> String { "varrida \(age)" }
    static func productActiveSessions(_ n: Int) -> String { "× \(n)" }
    static func productElapsedBar(_ clock: String) -> String { "‖ \(clock)" }

    static func spokenIncidentLine(_ incident: AtlasNativeSnapshot.Fleet.Incident?) -> String? {
        LockAccessoryA11y.spokenIncidentLine(incident)
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
    static func productDeliveryCaption(_ delivery: AtlasNativeSnapshot.Fleet.LastDelivery) -> String? {
        let title = delivery.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !title.isEmpty { return "última entrega \(title)" }
        let hash = delivery.mergeHash.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !hash.isEmpty else { return nil }
        return "última entrega \(String(hash.prefix(7)))"
    }
}

extension FleetWidgetA11y {
    static func contentPhaseID(snapshot: AtlasNativeSnapshot, stale: Bool) -> String {
        let incident = spokenIncidentLine(snapshot.fleet?.incident) ?? ""
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
              let caption = productDeliveryCaption(delivery) else { return nil }
        return caption
    }
}

extension FleetWidgetA11y {
    static func spokenIncidentPresentParts(snapshot: AtlasNativeSnapshot) -> [String]? {
        if let line = spokenIncidentLine(snapshot.fleet?.incident) {
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
           let caption = FleetWidgetA11y.productDeliveryCaption(delivery) {
            Text(caption)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Ink.ink2)
                .lineLimit(1)
        }
    }
}

extension FleetWidgetView {
    func fleetStaleLineText(age: String) -> some View {
        Text(LiveSessionWidgetA11y.productSeen(age))
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
            Text(FleetWidgetA11y.productFleetKicker)
                .font(.system(size: 14, weight: .semibold, design: .serif))
            Spacer()
            fleetHeaderStaleLine(stale: stale, age: age)
        }
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetHealthyScanned(_ snapshot: AtlasNativeSnapshot, scanned: Date) -> some View {
        Text(FleetWidgetA11y.productFleetIntact)
            .font(.system(size: 18, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.healed)
        Text(FleetWidgetA11y.productScanned(scanned.relativeShort(to: entry.date)))
            .font(.system(size: 12, design: .serif))
            .foregroundStyle(Ink.ink2)
    }
}

extension FleetWidgetView {
    var fleetHealthyUnread: some View {
        Text(FleetWidgetA11y.productFleetUnread)
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
            Text(FleetWidgetA11y.productFleetAttention)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.alert)
                .lineLimit(2)
        }
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetStateIncident(_ snapshot: AtlasNativeSnapshot) -> some View {
        if let line = FleetWidgetA11y.spokenIncidentLine(snapshot.fleet?.incident) {
            fleetStateIncidentLineText(line)
        } else {
            fleetStateIncidentPresent(snapshot)
        }
    }
}

extension FleetWidgetView {
    @ViewBuilder
    func fleetState(_ snapshot: AtlasNativeSnapshot) -> some View {
        if snapshot.fleet?.incident?.present == true || FleetWidgetA11y.spokenIncidentLine(snapshot.fleet?.incident) != nil {
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

// MARK: - LockAccessoryWidgetSurface

// MARK: - Circular gauge

extension LockAccessorySnapshotView {
    func circularGaugeSymbol(incident: Bool, attention: Bool) -> String {
        incident ? "!" : (attention ? "‖" : "◆")
    }

    func productGaugeValue(count: Int, incident: Bool) -> String {
        incident ? "!" : "\(count)"
    }
}

extension LockAccessorySnapshotView {
    func circularGauge(count: Int, attention: Bool, incident: Bool) -> some View {
        Gauge(value: Double(min(count, 5)), in: 0...5) {
            Text(circularGaugeSymbol(incident: incident, attention: attention))
        } currentValueLabel: {
            Text(productGaugeValue(count: count, incident: incident))
                .foregroundStyle(incident || attention ? Ink.alert : Ink.ink)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(incident || attention ? Ink.alert : Ink.gold)
        .transaction { transaction in
            if reduceMotion { transaction.disablesAnimations = true }
        }
    }
}

extension LockAccessorySnapshotView {
    func circular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let count = snapshot.liveSessions?.count ?? 0
        let attention = LockAccessoryA11y.hasAttention(snapshot)
        let incident = LockAccessoryA11y.spokenIncidentLine(snapshot.fleet?.incident) != nil
        return circularGauge(count: count, attention: attention, incident: incident)
    }
}

// MARK: - Types

enum LockAccessoryA11y {
    static func hasAttention(_ snapshot: AtlasNativeSnapshot) -> Bool {
        snapshot.liveSessions?.contains { $0.timing == .paused } == true
    }

    static func spokenIncidentLine(_ incident: AtlasNativeSnapshot.Fleet.Incident?) -> String? {
        guard let incident, incident.present else { return nil }
        if let action = incident.recommendedAction?
            .trimmingCharacters(in: .whitespacesAndNewlines), !action.isEmpty {
            return action
        }
        return incident.flags.lazy
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first(where: { !$0.isEmpty })
    }
}

extension LockAccessoryA11y {
    static func frozenClock(_ session: AtlasNativeSnapshot.LiveSession) -> String? {
        guard session.timing == .paused, let ms = session.elapsedActiveMs else { return nil }
        return AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}

extension LockAccessoryA11y {
    static func contentPhaseID(snapshot: AtlasNativeSnapshot, stale: Bool) -> String {
        let incident = spokenIncidentLine(snapshot.fleet?.incident) ?? ""
        let paused = hasAttention(snapshot) ? "p" : "r"
        let n = snapshot.liveSessions?.count ?? 0
        let phase = snapshot.liveSessions?.first?.phaseTitle ?? ""
        return "\(incident)|\(paused)|\(n)|\(phase)|\(stale)"
    }
}

extension LockAccessoryA11y {
    static func rectangularPausedSubtitle(_ first: AtlasNativeSnapshot.LiveSession) -> String {
        if let clock = frozenClock(first) { return "‖ \(clock)" }
        return "‖ pausado"
    }
}

extension LockAccessoryA11y {
    static func rectangularSubtitle(_ snapshot: AtlasNativeSnapshot) -> String? {
        guard let sessions = snapshot.liveSessions, let first = sessions.first else {
            return "nenhuma sessão viva agora"
        }
        if first.timing == .paused {
            return rectangularPausedSubtitle(first)
        }
        if sessions.count > 1 { return "\(sessions.count) sessões vivas" }
        return nil
    }
}

extension LockAccessoryA11y {
    static func inlineText(_ snapshot: AtlasNativeSnapshot) -> String {
        if LockAccessoryA11y.spokenIncidentLine(snapshot.fleet?.incident) != nil {
            return "Atlas · frota"
        }
        if hasAttention(snapshot) { return "Atlas · pausado" }
        let n = snapshot.liveSessions?.count ?? 0
        if n == 0 { return "Atlas · silêncio" }
        return "Atlas · \(n) executando"
    }
}

extension LockAccessoryA11y {}

extension LockAccessorySnapshotView {
    @ViewBuilder
    // MARK: - Family branches

func lockAccessoryFamilyBranch(_ snapshot: AtlasNativeSnapshot) -> some View {
        if family == .accessoryCircular {
            lockAccessoryCircularContent(snapshot)
        } else if family == .accessoryInline {
            lockAccessoryInlineContent(snapshot)
        } else {
            lockAccessoryRectangularContent(snapshot)
        }
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        lockAccessoryFamilyBranch(snapshot)
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryCircularContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        circular(snapshot)
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryInlineContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        Text(LockAccessoryA11y.inlineText(snapshot))
            .foregroundStyle(emphasisColor(snapshot))
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func lockAccessoryRectangularContent(_ snapshot: AtlasNativeSnapshot) -> some View {
        rectangular(snapshot)
    }
}

extension LockAccessorySnapshotView {
    var lockAccessoryEmpty: some View {
        Text(FleetWidgetA11y.productOpenAtlas)
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    // MARK: - Snapshot shell

var snapshotBranch: some View {
        if let snapshot = entry.snapshot {
            lockAccessoryContent(snapshot)
        } else {
            lockAccessoryEmpty
        }
    }
}

extension LockAccessoryA11y {
    static func spokenAttentionLine(_ snapshot: AtlasNativeSnapshot) -> String? {
        guard hasAttention(snapshot),
              let paused = snapshot.liveSessions?.first(where: { $0.timing == .paused }) else {
            return nil
        }
        var parts = ["\(paused.title), pausado"]
        if let clock = frozenClock(paused) { parts.append("tempo congelado \(clock)") }
        return parts.joined(separator: ", ")
    }
}

extension LockAccessoryA11y {
    static func spokenLabelAlertLines(snapshot: AtlasNativeSnapshot) -> [String]? {
        if let line = spokenIncidentLine(snapshot.fleet?.incident) {
            return ["frota, \(line)"]
        }
        if let attention = spokenAttentionLine(snapshot) {
            return [attention]
        }
        return nil
    }
}

extension LockAccessoryA11y {
    static func spokenLabelBranchLines(snapshot: AtlasNativeSnapshot) -> [String] {
        if let alert = spokenLabelAlertLines(snapshot: snapshot) { return alert }
        if let sessions = snapshot.liveSessions, !sessions.isEmpty {
            return spokenLiveSessions(sessions)
        }
        return ["silêncio na obra"]
    }
}

extension LockAccessoryA11y {
    static func spokenLabelStaleSuffix(stale: Bool, age: String) -> String? {
        stale ? "visto \(age)" : nil
    }
}

extension LockAccessoryA11y {
    static func spokenLabel(snapshot: AtlasNativeSnapshot, stale: Bool, age: String) -> String {
        var parts: [String] = ["Atlas lock"]
        parts.append(contentsOf: spokenLabelBranchLines(snapshot: snapshot))
        if let suffix = spokenLabelStaleSuffix(stale: stale, age: age) {
            parts.append(suffix)
        }
        return parts.joined(separator: ", ")
    }
}

extension LockAccessorySnapshotView {
    var spokenLabel: String {
        guard let snapshot = entry.snapshot else { return "abra o Atlas para atualizar o snapshot" }
        return LockAccessoryA11y.spokenLabel(
            snapshot: snapshot,
            stale: snapshot.isStale(at: entry.date),
            age: snapshot.ageText(at: entry.date)
        )
    }
}

extension LockAccessoryA11y {
    static func spokenLiveSessions(_ sessions: [AtlasNativeSnapshot.LiveSession]) -> [String] {
        let n = sessions.count
        guard let first = sessions.first else {
            return ["\(n) sessões vivas"]
        }
        return [n == 1
            ? "\(first.title), \(first.phaseTitle), em execução"
            : "\(n) sessões vivas, \(first.phaseTitle)"]
    }
}

struct LockAccessorySnapshotView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let entry: SnapshotEntry

    // MARK: - Body

    var body: some View {
        Group { snapshotBranch }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(spokenLabel)
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularAlertBody(
        _ snapshot: AtlasNativeSnapshot,
        incidentLine: String?
    ) -> some View {
        if let incidentLine {
            rectangularIncidentBody(incidentLine)
        } else if let paused = snapshot.liveSessions?.first(where: { $0.timing == .paused }) {
            rectangularPausedBody(paused, snapshot: snapshot)
        }
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularIncidentBody(_ incidentLine: String) -> some View {
        Text(incidentLine)
            .font(.system(size: 13, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.alert)
            .lineLimit(2)
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularBody(_ snapshot: AtlasNativeSnapshot, stale: Bool, incidentLine: String?) -> some View {
        if incidentLine != nil || snapshot.liveSessions?.contains(where: { $0.timing == .paused }) == true {
            rectangularAlertBody(snapshot, incidentLine: incidentLine)
        } else {
            rectangularQuietBody(snapshot, stale: stale)
        }
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularPausedBody(_ paused: AtlasNativeSnapshot.LiveSession, snapshot: AtlasNativeSnapshot) -> some View {
        Text(paused.phaseTitle)
            .font(.system(size: 13, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.alert)
            .lineLimit(1)
        if let sub = LockAccessoryA11y.rectangularSubtitle(snapshot) {
            Text(sub)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Ink.alert)
        }
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularQuietStaleSubtitle(_ snapshot: AtlasNativeSnapshot) -> some View {
        Text(LiveSessionWidgetA11y.productSeen(snapshot.ageText(at: entry.date)))
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(Ink.alert)
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularQuietSubtitle(_ snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        if stale {
            rectangularQuietStaleSubtitle(snapshot)
        } else if let sub = LockAccessoryA11y.rectangularSubtitle(snapshot) {
            Text(sub)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }
}

extension LockAccessorySnapshotView {
    func rectangularQuietTitle(_ snapshot: AtlasNativeSnapshot) -> some View {
        Text(snapshot.liveSessions?.first?.phaseTitle ?? "silêncio na obra")
            .font(.system(size: 13, weight: .semibold, design: .serif))
            .lineLimit(1)
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
    func rectangularQuietBody(_ snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        rectangularQuietTitle(snapshot)
        rectangularQuietSubtitle(snapshot, stale: stale)
    }
}

extension LockAccessorySnapshotView {
    func rectangular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let stale = snapshot.isStale(at: entry.date)
        let incidentLine = LockAccessoryA11y.spokenIncidentLine(snapshot.fleet?.incident)
        return VStack(alignment: .leading, spacing: 2) {
            rectangularBody(snapshot, stale: stale, incidentLine: incidentLine)
        }
        .id(LockAccessoryA11y.contentPhaseID(snapshot: snapshot, stale: stale))
        .transaction { transaction in
            if reduceMotion { transaction.disablesAnimations = true }
        }
    }
}

extension LockAccessorySnapshotView {
    func emphasisColor(_ snapshot: AtlasNativeSnapshot) -> Color {
        if LockAccessoryA11y.spokenIncidentLine(snapshot.fleet?.incident) != nil
            || LockAccessoryA11y.hasAttention(snapshot) {
            return Ink.alert
        }
        return Ink.ink
    }
}

// MARK: - CodeWeekWidgetSurface

// MARK: - Types

enum CodeWeekWidgetA11y {}

extension CodeWeekWidgetA11y {
    static func isQuiet(_ week: AtlasNativeSnapshot.Week) -> Bool {
        week.commits == 0 && week.heals == 0 && week.prevented == 0
    }
}

extension CodeWeekWidgetA11y {
    static func spokenActiveWeekParts(_ week: AtlasNativeSnapshot.Week) -> [String] {
        var parts = ["Semana \(week.window)"]
        if week.commits > 0 { parts.append("\(week.commits) commit\(week.commits == 1 ? "" : "s")") }
        if week.heals > 0 { parts.append("\(week.heals) cura\(week.heals == 1 ? "" : "s")") }
        if week.prevented > 0 { parts.append("\(week.prevented) prevenido\(week.prevented == 1 ? "" : "s")") }
        return parts
    }
}

extension CodeWeekWidgetA11y {
    static func spokenQuietWeekParts(_ week: AtlasNativeSnapshot.Week) -> [String] {
        ["Semana \(week.window), semana quieta, sem commits nem curas"]
    }
}

extension CodeWeekWidgetA11y {
    static func spokenLabel(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> String {
        var parts = isQuiet(week)
            ? spokenQuietWeekParts(week)
            : spokenActiveWeekParts(week)
        if stale { parts.append("visto \(age)") }
        return parts.joined(separator: ", ")
    }
}

extension CodeWeekWidgetView {
    func weekBodyA11y<V: View>(
        _ content: V,
        week: AtlasNativeSnapshot.Week,
        stale: Bool,
        age: String
    ) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(CodeWeekWidgetA11y.spokenLabel(week: week, stale: stale, age: age))
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekBodyStack(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            weekHeader(week: week, stale: stale, age: age)
            weekMetricsOrQuiet(week)
            weekLargeHint(week)
            Spacer(minLength: 0)
        }
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekBody(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        weekBodyA11y(weekBodyStack(week: week, stale: stale, age: age), week: week, stale: stale, age: age)
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func codeWeekPublishedView(snapshot: AtlasNativeSnapshot) -> some View {
        if let week = snapshot.week {
            let stale = snapshot.isStale(at: entry.date)
            weekBody(week: week, stale: stale, age: snapshot.ageText(at: entry.date))
        } else {
            unpublishedWeek
        }
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func codeWeekEntryView(snapshot: AtlasNativeSnapshot?) -> some View {
        if let snapshot {
            codeWeekPublishedView(snapshot: snapshot)
        } else {
            InstallPromptView()
        }
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekHeaderStaleLine(stale: Bool, age: String) -> some View {
        if stale {
            Text(LiveSessionWidgetA11y.productSeen(age))
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        }
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekHeaderTitleRow(week: AtlasNativeSnapshot.Week) -> some View {
        HStack {
            Text(FleetWidgetA11y.productWeekKicker)
                .font(.system(size: 14, weight: .semibold, design: .serif))
            Spacer()
            Text(week.window)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekHeader(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        weekHeaderTitleRow(week: week)
        weekHeaderStaleLine(stale: stale, age: age)
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekLargeHint(_ week: AtlasNativeSnapshot.Week) -> some View {
        if family == .systemLarge {
            Text(CodeWeekWidgetA11y.isQuiet(week)
                 ? "abra o radar do Código para ver o grafo"
                 : "abra o radar do Código para o grafo")
                .font(.system(size: 12, design: .serif))
                .foregroundStyle(Ink.ink2)
        }
    }
}

extension CodeWeekWidgetView {
    func weekMetric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink)
            Text(label)
                .font(.system(size: 10, design: .serif))
                .foregroundStyle(Ink.ink2)
        }
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsPrimary(_ week: AtlasNativeSnapshot.Week) -> some View {
        if week.commits > 0 { weekMetric("\(week.commits)", "commits") }
        if week.heals > 0 { weekMetric("\(week.heals)", "curas") }
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsStack(_ week: AtlasNativeSnapshot.Week) -> some View {
        HStack(spacing: 14) {
            weekMetricsPrimary(week)
            if week.prevented > 0 { weekMetric("\(week.prevented)", "prevenidos") }
        }
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekQuietBranch() -> some View {
        Text(FleetWidgetA11y.productQuietWeek)
            .font(.system(size: 16, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.ink2)
            .lineLimit(2)
    }
}

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsOrQuiet(_ week: AtlasNativeSnapshot.Week) -> some View {
        if CodeWeekWidgetA11y.isQuiet(week) {
            weekQuietBranch()
        } else {
            weekMetricsStack(week)
        }
    }
}

extension CodeWeekWidgetView {
    var unpublishedWeek: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(FleetWidgetA11y.productWeekKicker)
                .font(.system(size: 14, weight: .semibold, design: .serif))
            Text(FleetWidgetA11y.productWeekUnpublished)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink2)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(FleetWidgetA11y.productWeekUnpublished)
    }
}

struct CodeWeekWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: SnapshotEntry

    // MARK: - Body

    var body: some View {
        SnapshotContainer {
            AnyView(codeWeekEntryView(snapshot: entry.snapshot))
        }
        .widgetURL(URL(string: "atlas://code"))
    }
}

// MARK: - AtlasTurnLiveActivity

// MARK: - Widget host

struct AtlasTurnLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AtlasTurnAttributes.self) { context in
            LockScreenView(context: context)
                .activityBackgroundTint(Ink.bg)
                .activitySystemActionForegroundColor(Ink.gold)
                .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
        } dynamicIsland: { context in
            dynamicIslandContent(context: context)
        }
    }
}

extension AtlasTurnLiveActivity {
    // MARK: - Dynamic Island

func dynamicIslandContent(context: ActivityViewContext<AtlasTurnAttributes>) -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                AtlasTurnIslandCompactLeading(context: context)
            }
            DynamicIslandExpandedRegion(.center) {
                AtlasTurnIslandCenter(context: context)
            }
            DynamicIslandExpandedRegion(.trailing) {
                AtlasTurnIslandTrailing(context: context)
            }
        } compactLeading: {
            AtlasTurnIslandCompactLeading(context: context)
        } compactTrailing: {
            AtlasTurnIslandCompactTrailing(context: context)
        } minimal: {
            AtlasTurnIslandMinimal(context: context)
        }
        .keylineTint(context.state.atlasColor)
        .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
    }
}

// MARK: - Island compact

struct AtlasTurnIslandCompactLeading: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.glanceFace == .multiSession {
            Text("\(context.state.atlasSymbol)\(context.state.activeSessions)")
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(context.state.atlasColor)
        } else {
            Text(context.state.atlasSymbol)
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(context.state.atlasColor)
        }
    }
}

struct AtlasTurnIslandCompactTrailing: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        switch context.state.glanceFace {
        case .finished:
            Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                .foregroundStyle(Ink.healed)
                .accessibilityLabel(FleetWidgetA11y.productDone)
        case .paused:
            if let badge = context.state.phaseBadge {
                Text(badge)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Ink.alert)
            } else {
                Text("‖").font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.ink2)
            }
        case .multiSession, .running:
            if let badge = context.state.phaseBadge {
                Text(badge)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Ink.alert)
            } else if context.state.queueLabel != nil, context.state.progressLabel == nil,
                      let queued = context.state.queueLabel {
                Text(queued)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Ink.gold)
                    .accessibilityLabel(queued)
            } else if let progress = context.state.progressLabel {
                Text(progress)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Ink.gold)
            } else if context.state.showsGlanceTimer {
                AtlasTurnWidgetTimer(
                    startedAt: context.state.startedAt,
                    paused: context.state.paused,
                    pausedDisplay: context.state.pausedDisplay,
                    fontSize: 12,
                    frameWidth: 40
                )
            }
        }
    }
}

// MARK: - Island expanded

struct AtlasTurnIslandCenter: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.threadTitle)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(Ink.ink).lineLimit(1)
                Text(context.state.phaseTitle)
                    .font(.system(size: 12, design: .serif)).italic()
                    .foregroundStyle(Ink.ink2).lineLimit(1)
            }
            if context.state.progressLabel != nil || context.state.queueLabel != nil {
                HStack(spacing: 6) {
                    if let progress = context.state.progressLabel {
                        Text(progress)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Ink.gold)
                    }
                    if let queued = context.state.queueLabel {
                        Text(queued)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Ink.gold)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Ink.gold.opacity(0.18)))
                            .accessibilityLabel(queued)
                    }
                }
            }
        }
    }
}

struct AtlasTurnIslandTrailing: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        switch context.state.glanceFace {
        case .finished:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Ink.healed).padding(.trailing, 6)
                .accessibilityLabel(FleetWidgetA11y.productDone)
        case .paused, .multiSession, .running:
            if let badge = context.state.phaseBadge {
                Text(badge)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(Ink.alert)
                    .padding(.trailing, 6)
                    .accessibilityLabel(context.state.phaseTitle)
            } else if context.state.showsGlanceTimer {
                AtlasTurnWidgetTimer(
                    startedAt: context.state.startedAt,
                    paused: context.state.paused,
                    pausedDisplay: context.state.pausedDisplay,
                    fontSize: context.state.paused == true ? 12 : 13,
                    frameWidth: 44,
                    trailingPadding: 6
                )
            }
        }
    }
}

// MARK: - Island minimal

struct AtlasTurnIslandMinimal: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        if context.state.glanceFace != .finished, let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        } else if context.state.glanceFace != .finished, let progress = context.state.progressLabel {
            Text(progress)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(context.state.atlasColor)
        } else {
            Text(context.state.atlasSymbol)
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(context.state.atlasColor)
        }
    }
}

// MARK: - AtlasTurnLockScreen

struct LockScreenView: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        HStack(spacing: 14) {
            lockScreenLeadingColumn
            Spacer()
            trailingStatus
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
    }

    @ViewBuilder
    var lockScreenLeadingColumn: some View {
        Text(context.state.atlasSymbol)
            .font(.system(size: 28, design: .serif))
            .foregroundStyle(context.state.atlasColor)
            .shadow(color: context.state.atlasColor.opacity(0.35), radius: 4)
        VStack(alignment: .leading, spacing: 3) {
            titleBadges
            phaseLine
            progressLine
        }
    }

    var titleBadges: some View {
        HStack(spacing: 7) {
            Text(context.attributes.threadTitle)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink).lineLimit(1)
            activeSessionsBadge
            queueCapsule
        }
    }

    @ViewBuilder
    var activeSessionsBadge: some View {
        if context.state.glanceFace == .multiSession {
            Text(FleetWidgetA11y.productActiveSessions(context.state.activeSessions))
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.gold)
                .padding(.horizontal, 7).padding(.vertical, 2)
                .background(Capsule().fill(Ink.gold.opacity(0.14)))
        }
    }

    @ViewBuilder
    var queueCapsule: some View {
        if let queued = context.state.queueLabel {
            Text(queued)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.gold)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(Ink.gold.opacity(0.22)))
                .overlay(Capsule().stroke(Ink.gold.opacity(0.45), lineWidth: 0.5))
                .accessibilityLabel(queued)
        }
    }

    var phaseLine: some View {
        HStack(spacing: 6) {
            phaseBadgeChip
            Text(context.state.phaseTitle)
                .font(.system(size: 13, design: .serif)).italic()
                .foregroundStyle(context.state.silenceHealthyFinished ? Ink.healed : context.state.atlasColor)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    var phaseBadgeChip: some View {
        if let badge = context.state.phaseBadge {
            Text(badge)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Ink.alert)
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Capsule().fill(Ink.alert.opacity(0.16)))
                .accessibilityLabel(context.state.phaseTitle)
        }
    }

    @ViewBuilder
    var progressLine: some View {
        if let progress = context.state.progressLabel {
            Text(progress)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }

    @ViewBuilder
    var trailingStatus: some View {
        // Face exclusive: finished silences timer (no false 0:00).
        if context.state.glanceFace == .finished {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22)).foregroundStyle(Ink.healed)
                .accessibilityLabel(FleetWidgetA11y.productDone)
        } else if context.state.showsGlanceTimer {
            AtlasTurnWidgetTimer(
                startedAt: context.state.startedAt,
                paused: context.state.paused,
                pausedDisplay: context.state.pausedDisplay,
                fontSize: 15,
                frameWidth: 52
            )
        }
    }
}

// MARK: - AtlasTurnGlanceJudgment

enum AtlasTurnGlanceFace: String, Equatable {
    case finished
    case multiSession
    case paused
    case running

    /// WAVE-023 product vocabulary (multiSession ↔ multi).
    var productWord: String {
        switch self {
        case .finished: return "finished"
        case .multiSession: return "multi"
        case .paused: return "paused"
        case .running: return "running"
        }
    }
}

extension AtlasTurnAttributes.ContentState {
    /// Mutual-exclusive face for glance chrome (DoD WAVE-018).
    var glanceFace: AtlasTurnGlanceFace {
        if finished { return .finished }
        if activeSessions > 1 { return .multiSession }
        if paused == true { return .paused }
        return .running
    }

    var isFailed: Bool {
        phaseTitle.localizedCaseInsensitiveContains("falhou")
    }

    var isAttention: Bool {
        phaseTitle.localizedCaseInsensitiveContains("atenção")
            || phaseTitle.localizedCaseInsensitiveContains("aguard")
            || phaseTitle.localizedCaseInsensitiveContains("decisão")
    }

    /// Timer only when not finished (no false 0:00 after terminal).
    var showsGlanceTimer: Bool {
        !finished
    }

    /// Silence gold chrome when finished healthy (no fail badge).
    var silenceHealthyFinished: Bool {
        finished && !isFailed
    }

    var atlasColorTerminal: Color? {
        if isFailed { return Ink.alert }
        if finished { return Ink.healed }
        return nil
    }

    var atlasColor: Color {
        if let terminal = atlasColorTerminal { return terminal }
        if paused == true || isAttention { return Ink.alert }
        return Ink.gold
    }

    var atlasSymbolTerminal: String? {
        if isFailed { return "✕" }
        if finished { return "✓" }
        return nil
    }

    var atlasSymbol: String {
        if let terminal = atlasSymbolTerminal { return terminal }
        if isAttention { return "⚠" }
        if paused == true { return "‖" }
        return "✦"
    }

    /// SD-2: badge from canonical phaseTitle only.
    var phaseBadge: String? {
        phaseBadgeFailAtt ?? phaseBadgeExtRecPln
    }

    var phaseBadgeFailAtt: String? {
        let p = phaseTitle.lowercased()
        if p.contains("falhou") { return "FAIL" }
        if p.contains("atenção") || p.contains("decisão") { return "ATT" }
        return nil
    }

    var phaseBadgeExtRecPln: String? {
        let p = phaseTitle.lowercased()
        if p.contains("sistema externo") || (p.contains("aguard") && p.contains("extern")) {
            return "EXT"
        }
        if p.contains("reconect") { return "REC" }
        if p.contains("replanej") { return "PLN" }
        return nil
    }

    var progressLabel: String? {
        guard let current = progressCurrent, let total = progressTotal, total > 0 else { return nil }
        return "\(min(max(current, 0), total))/\(total)"
    }

    var queueLabel: String? {
        guard let count = queuedCount, count > 0 else { return nil }
        return "fila \(count)"
    }
}

// MARK: - AtlasWidgetViews

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
            Text(FleetWidgetA11y.productAtlasKicker)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.gold)
            Text(FleetWidgetA11y.productOpenAtlas)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink)
        }
    }
}

// MARK: - LiveSessionWidgetTimer

struct LiveSessionWidgetTimer: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let live: AtlasNativeSnapshot.LiveSession

    var body: some View {
        timerStyle(Group { timerBranchBody })
    }
}

extension LiveSessionWidgetTimer {
    @ViewBuilder
    func activeClock(since: Date) -> some View {
        if reduceMotion {
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                Text(clock(elapsedMs(since: since, now: timeline.date)))
            }
        } else {
            Text(since, style: .timer)
        }
    }
}

extension LiveSessionWidgetTimer {
    @ViewBuilder
    var timerFallbackBody: some View {
        if live.timing == .paused {
            Text(FleetWidgetA11y.productElapsedBar(clock(live.elapsedActiveMs)))
        } else if let ms = live.elapsedActiveMs {
            Text(clock(ms))
        }
    }
}

extension LiveSessionWidgetTimer {
    func elapsedMs(since: Date, now: Date) -> Int {
        Int(max(0, now.timeIntervalSince(since)) * 1000)
    }

    func clock(_ ms: Int?) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms ?? 0)
    }
}

extension LiveSessionWidgetView {
    func liveSessionTitleLine(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        Text(live.title)
            .font(.system(size: 17, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.ink)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTitles(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTitleLine(live)
        Text(live.phaseTitle)
            .font(.system(size: 14, design: .serif))
            .italic()
            .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

struct LiveSessionWidgetView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let entry: SnapshotEntry

    var body: some View {
        liveSessionSnapshotGate { snapshot, live, stale in
            liveSessionContent(snapshot: snapshot, live: live, stale: stale)
        }
        .widgetURL(URL(string: "atlas://execution"))
    }
}
