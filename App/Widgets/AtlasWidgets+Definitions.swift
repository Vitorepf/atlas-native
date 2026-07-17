import WidgetKit
import SwiftUI
import AtlasCore

// Definições dos widgets de snapshot — peel de AtlasWidgets.

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
