import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Snapshot widget surfaces (lock accessory / live session)

struct LockAccessorySnapshotView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SnapshotEntry

    var body: some View {
        if let snapshot = entry.snapshot {
            switch family {
            case .accessoryCircular:
                circular(snapshot)
            case .accessoryInline:
                Text(inlineText(snapshot))
                    .foregroundStyle(emphasisColor(snapshot))
            default:
                rectangular(snapshot)
            }
        } else {
            Text("abra o Atlas")
        }
    }

    private func circular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let count = snapshot.liveSessions?.count ?? 0
        let attention = hasAttention(snapshot)
        let incident = snapshot.fleet?.incident?.present == true
        return Gauge(value: Double(min(count, 5)), in: 0...5) {
            Text(incident ? "!" : (attention ? "⚠" : "◆"))
        } currentValueLabel: {
            Text(incident ? "!" : "\(count)")
                .foregroundStyle(incident || attention ? Ink.alert : Ink.ink)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(incident || attention ? Ink.alert : Ink.gold)
    }

    private func rectangular(_ snapshot: AtlasNativeSnapshot) -> some View {
        let stale = snapshot.isStale(at: entry.date)
        let attention = hasAttention(snapshot)
        let incident = snapshot.fleet?.incident
        return VStack(alignment: .leading, spacing: 2) {
            if let incident, incident.present {
                Text(incident.recommendedAction ?? incident.flags.first ?? "incidente na frota")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(Ink.alert)
                    .lineLimit(2)
            } else if attention, let paused = snapshot.liveSessions?.first(where: { $0.timing == .paused }) {
                Text(paused.phaseTitle)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundStyle(Ink.alert)
                    .lineLimit(1)
                Text("‖ atenção")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Ink.alert)
            } else {
                Text(snapshot.liveSessions?.first?.phaseTitle ?? "Atlas em silêncio")
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .lineLimit(1)
                Text(stale ? "visto \(snapshot.ageText(at: entry.date))" : rectangularSubtitle(snapshot))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(stale ? Ink.alert : Ink.ink2)
            }
        }
    }

    private func rectangularSubtitle(_ snapshot: AtlasNativeSnapshot) -> String {
        guard let sessions = snapshot.liveSessions, let first = sessions.first else {
            return "0 sessões vivas"
        }
        if first.timing == .paused { return "‖ pausado" }
        if let ms = first.elapsedActiveMs {
            return "\(sessions.count) · \(Self.formatElapsed(ms))"
        }
        return "\(sessions.count) sessões vivas"
    }

    private func inlineText(_ snapshot: AtlasNativeSnapshot) -> String {
        if snapshot.fleet?.incident?.present == true {
            return "Atlas · frota · incidente"
        }
        if hasAttention(snapshot) {
            return "Atlas · atenção"
        }
        let n = snapshot.liveSessions?.count ?? 0
        if n == 0 { return "Atlas · silêncio" }
        return "Atlas · \(n) executando"
    }

    private func emphasisColor(_ snapshot: AtlasNativeSnapshot) -> Color {
        if snapshot.fleet?.incident?.present == true || hasAttention(snapshot) {
            return Ink.alert
        }
        return Ink.ink
    }

    private func hasAttention(_ snapshot: AtlasNativeSnapshot) -> Bool {
        snapshot.liveSessions?.contains {
            $0.timing == .paused
                || $0.phaseTitle.localizedCaseInsensitiveContains("atenção")
                || $0.phaseTitle.localizedCaseInsensitiveContains("aguard")
        } == true
    }

    private static func formatElapsed(_ ms: Int) -> String {
        let total = max(0, ms / 1000)
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}

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
                    Text("nada executando")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                    Text("última concluída \(delivery.mergeHash.prefix(7))")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Ink.ink2)
                } else {
                    Text("nada executando")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                    Text("abra o Atlas para atualizar")
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
