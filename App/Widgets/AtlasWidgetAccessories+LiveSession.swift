import WidgetKit
import SwiftUI
import AtlasCore

// Home-screen live session widget — peel de LockLive (régua ~160).

struct LiveSessionWidgetView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let entry: SnapshotEntry

    var body: some View {
        SnapshotContainer {
            guard let snapshot = entry.snapshot else {
                return AnyView(InstallPromptView())
            }
            let stale = snapshot.isStale(at: entry.date)
            let live = snapshot.liveSessions?.first
            return AnyView(VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("✦ Sessão viva")
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                    Spacer()
                    if stale {
                        Text("visto \(snapshot.ageText(at: entry.date))")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Ink.alert)
                    }
                }
                if let live {
                    Text(live.title)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(Ink.ink)
                        .lineLimit(1)
                    Text(live.phaseTitle)
                        .font(.system(size: 14, design: .serif))
                        .italic()
                        .foregroundStyle(live.timing == .paused ? Ink.gold : Ink.ink2)
                        .lineLimit(1)
                    HStack {
                        LiveSessionWidgetTimer(live: live)
                        Spacer()
                        Text("Seguir")
                            .font(.system(size: 12, weight: .semibold, design: .serif))
                            .foregroundStyle(Ink.bg)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Ink.gold))
                            .accessibilityHidden(true)
                    }
                } else {
                    Text("silêncio na obra")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                    Text(LiveSessionWidgetA11y.silenceDetail(snapshot))
                        .font(.system(size: 12, design: .serif))
                        .foregroundStyle(Ink.ink2)
                }
            }
            .id(LiveSessionWidgetA11y.contentPhaseID(snapshot: snapshot, live: live, stale: stale))
            .transaction { transaction in
                if reduceMotion { transaction.disablesAnimations = true }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(LiveSessionWidgetA11y.spokenLabel(
                snapshot: snapshot,
                live: live,
                stale: stale,
                age: snapshot.ageText(at: entry.date)
            )))
        }
        .widgetURL(URL(string: "atlas://execution"))
    }
}
