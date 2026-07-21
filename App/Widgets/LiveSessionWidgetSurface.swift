import WidgetKit
import SwiftUI
import AtlasCore

// IDLE-COMPRESS — LiveSession home widget fused host.

// --- AtlasWidgetAccessories+LiveSession+A11y.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11yChrome+PhaseID.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11yChrome+SpokenBind.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11yChrome+TransactionBind.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11yChrome.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11yPhase.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11ySpoken+Core.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11ySpoken+Silence.swift ---
extension LiveSessionWidgetA11y {
    static func spokenSilenceParts(_ snapshot: AtlasNativeSnapshot) -> [String] {
        ["silêncio na obra", silenceDetail(snapshot)]
    }
}

// --- AtlasWidgetAccessories+LiveSession+A11ySpoken+Stale.swift ---
extension LiveSessionWidgetA11y {
    static func spokenStaleParts(stale: Bool, age: String) -> [String] {
        stale ? ["visto \(age)"] : []
    }
}

// --- AtlasWidgetAccessories+LiveSession+A11ySpoken.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11ySpokenBind+Combine.swift ---
extension LiveSessionWidgetView {
    func liveSessionSpokenCombine<Content: View>(_ content: Content) -> some View {
        content.accessibilityElement(children: .combine)
    }
}

// --- AtlasWidgetAccessories+LiveSession+A11ySpokenBind+Label.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11ySpokenBind.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11ySpokenLive.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+A11yTransaction.swift ---
extension LiveSessionWidgetView {
    func liveSessionA11yTransaction(_ transaction: inout Transaction) {
        if reduceMotion { transaction.disablesAnimations = true }
    }
}

// --- AtlasWidgetAccessories+LiveSession+Bodies+TimerBlock.swift ---
extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTimerBlock(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTimerRow(live)
    }
}

// --- AtlasWidgetAccessories+LiveSession+Bodies+TimerRow.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+Bodies+Titles.swift ---
extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionTitlesBlock(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTitles(live)
    }
}

// --- AtlasWidgetAccessories+LiveSession+Bodies.swift ---
extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionActiveBody(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionTitlesBlock(live)
        liveSessionTimerBlock(live)
    }
}

// --- AtlasWidgetAccessories+LiveSession+Content.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+ContentActive.swift ---
extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionActiveBranch(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        liveSessionActiveBody(live)
    }
}

// --- AtlasWidgetAccessories+LiveSession+ContentBranch.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+ContentHeader.swift ---
extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentHeader(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        liveSessionHeader(stale: stale, age: snapshot.ageText(at: entry.date))
    }
}

// --- AtlasWidgetAccessories+LiveSession+ContentSilence.swift ---
extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionSilenceBranch(_ snapshot: AtlasNativeSnapshot) -> some View {
        liveSessionSilenceBody(snapshot)
    }
}

// --- AtlasWidgetAccessories+LiveSession+ContentStack+Branch.swift ---
extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentBranchRow(
        snapshot: AtlasNativeSnapshot,
        live: AtlasNativeSnapshot.LiveSession?
    ) -> some View {
        liveSessionContentBranch(snapshot: snapshot, live: live)
    }
}

// --- AtlasWidgetAccessories+LiveSession+ContentStack+Header.swift ---
extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentHeaderRow(snapshot: AtlasNativeSnapshot, stale: Bool) -> some View {
        liveSessionContentHeader(snapshot: snapshot, stale: stale)
    }
}

// --- AtlasWidgetAccessories+LiveSession+ContentStack.swift ---
extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentStack(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            liveSessionContentHeaderRow(snapshot: snapshot, stale: stale)
            liveSessionContentBranchRow(snapshot: snapshot, live: live)
        }
    }
}

// --- AtlasWidgetAccessories+LiveSession+Follow.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+Header.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+Silence.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+SnapshotGate+Install.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+SnapshotGate.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+Timer+Branch.swift ---
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

// --- AtlasWidgetAccessories+LiveSession+Timer+Style.swift ---
extension LiveSessionWidgetTimer {
    @ViewBuilder
    func timerStyle<Content: View>(_ content: Content) -> some View {
        content
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
            .accessibilityHidden(true)
    }
}

// --- AtlasWidgetAccessories+LiveSession+Timer.swift ---
