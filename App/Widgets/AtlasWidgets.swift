import WidgetKit
import SwiftUI
import ActivityKit
import AtlasCore

// Superfícies externas do Atlas. Widgets/accessories leem somente o snapshot
// SD-1 no App Group; a Live Activity recebe estado via ActivityKit/APNs.
// Paleta em WidgetsInk.swift; provider/container em AtlasWidgetViews.swift;
// superfícies em AtlasWidgetAccessories.swift; lock screen em AtlasTurnLockScreen.swift.

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
                    } else if let badge = context.state.phaseBadge {
                        Text(badge)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(Ink.alert)
                            .padding(.trailing, 6)
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
                // SD-2: ordem honesta — terminal → fase tipada (ATT/EXT/FAIL…)
                // → pausa ‖ → N/M do plano → timer. Nunca inventa progresso.
                if context.state.finished {
                    Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Ink.healed)
                } else if let badge = context.state.phaseBadge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Ink.alert)
                } else if context.state.paused == true {
                    Text("‖").font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Ink.ink2)
                } else if let progress = context.state.progressLabel {
                    Text(progress)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Ink.gold)
                } else {
                    Text(context.state.startedAt, style: .timer)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Ink.ink2).frame(width: 40)
                }
            } minimal: {
                if let badge = context.state.phaseBadge, !context.state.finished {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Ink.alert)
                } else if let progress = context.state.progressLabel, !context.state.finished {
                    Text(progress)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(context.state.atlasColor)
                } else {
                    Text(context.state.atlasSymbol).font(.system(size: 14, design: .serif)).foregroundStyle(context.state.atlasColor)
                }
            }
            .keylineTint(context.state.atlasColor)
            .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
        }
    }
}
