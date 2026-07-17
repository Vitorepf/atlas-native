import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Superfícies externas do Atlas. Widgets/accessories leem somente o snapshot
// SD-1 no App Group; a Live Activity recebe estado via ActivityKit/APNs.
// A paleta mínima vive aqui e a serif é a do sistema (.fontDesign(.serif)).

private enum Ink {
    static let bg = Color(red: 0x1d / 255.0, green: 0x2b / 255.0, blue: 0x34 / 255.0)
    static let surface = Color(red: 0x24 / 255.0, green: 0x37 / 255.0, blue: 0x43 / 255.0)
    static let ink = Color(red: 0xd6 / 255.0, green: 0xdd / 255.0, blue: 0xe2 / 255.0)
    static let ink2 = Color(red: 0x95 / 255.0, green: 0xa3 / 255.0, blue: 0xac / 255.0)
    static let gold = Color(red: 0xd4 / 255.0, green: 0xa8 / 255.0, blue: 0x5a / 255.0)
    static let alert = Color(red: 0xe0 / 255.0, green: 0x75 / 255.0, blue: 0x5f / 255.0)
    static let healed = Color(red: 0x7f / 255.0, green: 0xb6 / 255.0, blue: 0x8f / 255.0)
}

@main
struct AtlasWidgetsBundle: WidgetBundle {
    var body: some Widget {
        AtlasFleetWidget()
        AtlasLockAccessoryWidget()
        AtlasLiveSessionWidget()
        AtlasCodeWeekWidget()
        AtlasTurnLiveActivity()
    }
}

private struct SnapshotEntry: TimelineEntry {
    let date: Date
    let snapshot: AtlasNativeSnapshot?
}

private struct SnapshotProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnapshotEntry {
        SnapshotEntry(date: .now, snapshot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
        completion(SnapshotEntry(date: .now, snapshot: Self.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
        let entry = SnapshotEntry(date: .now, snapshot: Self.load())
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(30 * 60))))
    }

    private static func load() -> AtlasNativeSnapshot? {
        guard let file = AtlasNativeSnapshotStore.appGroupFileURL() else { return nil }
        guard let data = try? Data(contentsOf: file) else { return nil }
        return try? JSONDecoder.atlasNativeSnapshotDecoder().decode(AtlasNativeSnapshot.self, from: data)
    }
}

struct AtlasFleetWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "atlas.fleet.snapshot", provider: SnapshotProvider()) { entry in
            FleetWidgetView(entry: entry)
        }
        .configurationDisplayName("Atlas · Frota")
        .description("Estado da frota por exceção, lendo só o snapshot local.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct AtlasLockAccessoryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "atlas.lock.snapshot", provider: SnapshotProvider()) { entry in
            LockAccessorySnapshotView(entry: entry)
        }
        .configurationDisplayName("Atlas · Agora")
        .description("Sessões vivas e atenção do Atlas na tela bloqueada.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct AtlasLiveSessionWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "atlas.live-session.snapshot", provider: SnapshotProvider()) { entry in
            LiveSessionWidgetView(entry: entry)
        }
        .configurationDisplayName("Atlas · Sessão viva")
        .description("Acompanha uma execução viva pelo snapshot do App Group.")
        .supportedFamilies([.systemMedium])
    }
}

/// M84 — A Semana do Código: lê só `snapshot.week` (já escrito pelo app).
struct AtlasCodeWeekWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "atlas.code.week.snapshot", provider: SnapshotProvider()) { entry in
            CodeWeekWidgetView(entry: entry)
        }
        .configurationDisplayName("Atlas · Semana do Código")
        .description("Commits, curas e prevenções da semana — só do snapshot local.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

private struct CodeWeekWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SnapshotEntry

    var body: some View {
        SnapshotContainer {
            guard let snapshot = entry.snapshot else {
                return AnyView(InstallPromptView())
            }
            guard let week = snapshot.week else {
                return AnyView(VStack(alignment: .leading, spacing: 6) {
                    Text("✦ Semana")
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                    Text("semana ainda não publicada")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(Ink.ink2)
                    Spacer(minLength: 0)
                })
            }
            let stale = snapshot.isStale(at: entry.date)
            return AnyView(VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("✦ Semana")
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                    Spacer()
                    Text(week.window)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Ink.ink2)
                }
                if stale {
                    Text("visto \(snapshot.ageText(at: entry.date))")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Ink.alert)
                }
                HStack(spacing: 14) {
                    weekMetric("\(week.commits)", "commits")
                    weekMetric("\(week.heals)", "curas")
                    weekMetric("\(week.prevented)", "prevenidos")
                }
                if family == .systemLarge {
                    Text("abra o radar do Código para o grafo")
                        .font(.system(size: 12, design: .serif))
                        .foregroundStyle(Ink.ink2)
                }
                Spacer(minLength: 0)
            })
        }
        .widgetURL(URL(string: "atlas://code"))
    }

    private func weekMetric(_ value: String, _ label: String) -> some View {
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

private struct FleetWidgetView: View {
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

private struct LockAccessorySnapshotView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SnapshotEntry

    var body: some View {
        if let snapshot = entry.snapshot {
            switch family {
            case .accessoryCircular:
                Gauge(value: Double(snapshot.liveSessions?.count ?? 0), in: 0...5) {
                    Text("◆")
                } currentValueLabel: {
                    Text("\(snapshot.liveSessions?.count ?? 0)")
                }
                .gaugeStyle(.accessoryCircular)
            case .accessoryInline:
                Text("Atlas · \(snapshot.liveSessions?.count ?? 0) executando")
            default:
                VStack(alignment: .leading, spacing: 2) {
                    Text(snapshot.liveSessions?.first?.phaseTitle ?? "Atlas em silêncio")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .lineLimit(1)
                    Text(snapshot.isStale(at: entry.date) ? "visto \(snapshot.ageText(at: entry.date))" : "\(snapshot.liveSessions?.count ?? 0) sessões vivas")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(snapshot.isStale(at: entry.date) ? Ink.alert : Ink.ink2)
                }
            }
        } else {
            Text("abra o Atlas")
        }
    }
}

private struct LiveSessionWidgetView: View {
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

private struct SnapshotContainer<Content: View>: View {
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

private struct InstallPromptView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("✦ Atlas")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.gold)
            Text("abra o Atlas")
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink)
        }
    }
}

private extension AtlasNativeSnapshot {
    func isStale(at now: Date) -> Bool {
        now.timeIntervalSince(generatedAt) > 6 * 60 * 60
    }

    func ageText(at now: Date) -> String {
        generatedAt.relativeShort(to: now)
    }
}

private extension Date {
    func relativeShort(to now: Date) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(self)))
        if seconds >= 86_400 { return "há \(seconds / 86_400)d" }
        if seconds >= 3_600 { return "há \(seconds / 3_600)h" }
        if seconds >= 60 { return "há \(seconds / 60)m" }
        return "agora"
    }
}

struct AtlasTurnLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AtlasTurnAttributes.self) { context in
            // ── Tela bloqueada / banner ──
            LockScreenView(context: context)
                .activityBackgroundTint(Ink.bg)
                .activitySystemActionForegroundColor(Ink.gold)
                .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(spacing: 2) {
                        Text("✦")
                            .font(.system(size: 24, design: .serif))
                            .foregroundStyle(context.state.atlasColor)
                        if context.state.activeSessions > 1 {
                            Text("× \(context.state.activeSessions)")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Ink.ink2)
                        }
                    }
                    .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.threadTitle)
                            .font(.system(size: 14, weight: .semibold, design: .serif))
                            .foregroundStyle(Ink.ink).lineLimit(1)
                        Text(context.state.phaseTitle)
                            .font(.system(size: 12, design: .serif)).italic()
                            .foregroundStyle(Ink.ink2).lineLimit(1)
                        if let progress = context.state.progressLabel {
                            Text(progress)
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Ink.gold)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.finished {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Ink.healed).padding(.trailing, 6)
                    } else if context.state.paused == true {
                        // C14: pausa do servidor congela o tempo ATIVO — a espera não conta
                        Text("‖ \(context.state.pausedDisplay ?? "—")")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(Ink.ink2).padding(.trailing, 6)
                    } else {
                        Text(context.state.startedAt, style: .timer)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(Ink.ink2)
                            .frame(width: 44).padding(.trailing, 6)
                    }
                }
            } compactLeading: {
                if context.state.activeSessions > 1 {
                    Text("\(context.state.atlasSymbol)\(context.state.activeSessions)")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundStyle(context.state.atlasColor)
                } else {
                    Text(context.state.atlasSymbol)
                        .font(.system(size: 15, design: .serif))
                        .foregroundStyle(context.state.atlasColor)
                }
            } compactTrailing: {
                if context.state.finished {
                    Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Ink.healed)
                } else if context.state.paused == true {
                    Text("‖").font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Ink.ink2)
                } else {
                    Text(context.state.startedAt, style: .timer)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Ink.ink2).frame(width: 40)
                }
            } minimal: {
                Text(context.state.atlasSymbol).font(.system(size: 14, design: .serif)).foregroundStyle(context.state.atlasColor)
            }
            .keylineTint(context.state.atlasColor)
            .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
        }
    }
}

private struct LockScreenView: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        HStack(spacing: 14) {
            Text(context.state.atlasSymbol)
                .font(.system(size: 28, design: .serif))
                .foregroundStyle(context.state.atlasColor)
                .shadow(color: context.state.atlasColor.opacity(0.35), radius: 4)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text(context.attributes.threadTitle)
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(Ink.ink).lineLimit(1)
                    if context.state.activeSessions > 1 {
                        Text("× \(context.state.activeSessions)")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Ink.gold)
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Capsule().fill(Ink.gold.opacity(0.14)))
                    }
                }
                Text(context.state.phaseTitle)
                    .font(.system(size: 13, design: .serif)).italic()
                    .foregroundStyle(context.state.finished ? Ink.healed : context.state.atlasColor.opacity(0.88))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if let progress = context.state.progressLabel {
                        Text(progress)
                    }
                    if let queued = context.state.queueLabel {
                        Text(queued)
                    }
                }
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
            }
            Spacer()
            if context.state.finished {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22)).foregroundStyle(Ink.healed)
            } else if context.state.paused == true {
                Text("‖ \(context.state.pausedDisplay ?? "—")")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(Ink.ink2)
            } else {
                Text(context.state.startedAt, style: .timer)
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundStyle(Ink.ink2)
                    .frame(width: 52)
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
    }
}

private extension AtlasTurnAttributes.ContentState {
    var atlasColor: Color {
        if phaseTitle.localizedCaseInsensitiveContains("falhou") { return Ink.alert }
        if finished { return Ink.healed }
        if paused == true { return Ink.gold }
        return Ink.gold
    }

    var atlasSymbol: String {
        if phaseTitle.localizedCaseInsensitiveContains("falhou") { return "✕" }
        if finished { return "✓" }
        if paused == true { return "‖" }
        return "✦"
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
