import WidgetKit
import SwiftUI
import AtlasCore

// IDLE-COMPRESS — Lock accessory widgets fused (presentation-only).

extension LockAccessorySnapshotView {
    func circularGaugeSymbol(incident: Bool, attention: Bool) -> String {
        incident ? "!" : (attention ? "‖" : "◆")
    }

    func circularGaugeValueLabel(count: Int, incident: Bool) -> String {
        incident ? "!" : "\(count)"
    }
}

extension LockAccessorySnapshotView {
    func circularGauge(count: Int, attention: Bool, incident: Bool) -> some View {
        Gauge(value: Double(min(count, 5)), in: 0...5) {
            Text(circularGaugeSymbol(incident: incident, attention: attention))
        } currentValueLabel: {
            Text(circularGaugeValueLabel(count: count, incident: incident))
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
        let incident = LockAccessoryA11y.incidentLine(snapshot.fleet?.incident) != nil
        return circularGauge(count: count, attention: attention, incident: incident)
    }
}

// MARK: - Types

enum LockAccessoryA11y {
    static func hasAttention(_ snapshot: AtlasNativeSnapshot) -> Bool {
        snapshot.liveSessions?.contains { $0.timing == .paused } == true
    }

    static func incidentLine(_ incident: AtlasNativeSnapshot.Fleet.Incident?) -> String? {
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
        let incident = incidentLine(snapshot.fleet?.incident) ?? ""
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
        if LockAccessoryA11y.incidentLine(snapshot.fleet?.incident) != nil {
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
        Text("abra o Atlas")
    }
}

extension LockAccessorySnapshotView {
    @ViewBuilder
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
        if let line = incidentLine(snapshot.fleet?.incident) {
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
        Text("visto \(snapshot.ageText(at: entry.date))")
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
        let incidentLine = LockAccessoryA11y.incidentLine(snapshot.fleet?.incident)
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
        if LockAccessoryA11y.incidentLine(snapshot.fleet?.incident) != nil
            || LockAccessoryA11y.hasAttention(snapshot) {
            return Ink.alert
        }
        return Ink.ink
    }
}
