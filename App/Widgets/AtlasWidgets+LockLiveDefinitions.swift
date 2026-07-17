import WidgetKit
import SwiftUI
import AtlasCore

// Lock + live session widget definitions — peel de AtlasWidgets+Definitions.

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
