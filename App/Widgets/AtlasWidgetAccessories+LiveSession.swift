import WidgetKit
import SwiftUI
import AtlasCore

// Home-screen live session widget — peel de LockLive (régua ~160).

struct LiveSessionWidgetView: View {
    let entry: SnapshotEntry

    var body: some View {
        SnapshotContainer {
            guard let snapshot = entry.snapshot else {
                return AnyView(InstallPromptView())
            }
            let live = snapshot.liveSessions?.first
            return AnyView(VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("✦ Sessão viva")
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                    Spacer()
                    if snapshot.isStale(at: entry.date) {
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
                        liveTimer(live)
                        Spacer()
                        Text("Seguir")
                            .font(.system(size: 12, weight: .semibold, design: .serif))
                            .foregroundStyle(Ink.bg)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Ink.gold))
                    }
                } else if let delivery = snapshot.fleet?.lastDelivery {
                    Text("silêncio na obra")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                    Text("última concluída \(delivery.mergeHash.prefix(7))")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Ink.ink2)
                } else {
                    Text("silêncio na obra")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                    Text("nenhuma sessão viva agora")
                        .font(.system(size: 12, design: .serif))
                        .foregroundStyle(Ink.ink2)
                }
            })
        }
        .widgetURL(URL(string: "atlas://execution"))
    }

    @ViewBuilder
    private func liveTimer(_ live: AtlasNativeSnapshot.LiveSession) -> some View {
        if live.timing == .paused {
            Text("‖ \(Self.clock(live.elapsedActiveMs))")
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(Ink.gold)
        } else if let since = live.runningSince.flatMap(AtlasTime.date) {
            Text(since, style: .timer)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        } else if let ms = live.elapsedActiveMs {
            Text(Self.clock(ms))
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }

    private static func clock(_ ms: Int?) -> String {
        let s = max(0, (ms ?? 0) / 1000)
        return s >= 3600 ? String(format: "%d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
                         : String(format: "%d:%02d", s / 60, s % 60)
    }
}
