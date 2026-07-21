import WidgetKit
import SwiftUI
import AtlasCore

// IDLE-COMPRESS — LiveSession home widget fused host.

// MARK: - Types

enum LiveSessionWidgetA11y {
    static func silenceDetail(_ snapshot: AtlasNativeSnapshot) -> String {
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
        ["silêncio na obra", silenceDetail(snapshot)]
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
        Text("Seguir")
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
            Text("✦ Sessão viva")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .accessibilityHidden(true)
            Spacer()
            if stale {
                Text("visto \(age)")
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
        Text("silêncio na obra")
            .font(.system(size: 17, weight: .semibold, design: .serif))
            .accessibilityHidden(true)
        Text(LiveSessionWidgetA11y.silenceDetail(snapshot))
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

