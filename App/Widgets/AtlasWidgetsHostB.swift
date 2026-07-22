import SwiftUI
import WidgetKit
import AtlasCore
import ActivityKit

// GOD-RESTRUCTURE: Widgets surfaces fused B

// MARK: - AtlasTurnWidget+Timer

struct AtlasTurnWidgetTimer: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let startedAt: Date
    let paused: Bool?
    let pausedDisplay: String?
    var fontSize: CGFloat = 13
    var frameWidth: CGFloat? = 44
    var trailingPadding: CGFloat = 0

    var body: some View {
        timerFrameChrome
            .accessibilityLabel(timerA11y)
    }

    var timerFrameChrome: some View {
        timerText
            .font(.system(size: fontSize, design: .monospaced))
            .foregroundStyle(Ink.ink2)
            .frame(width: frameWidth)
            .padding(.trailing, trailingPadding)
    }

    var timerA11y: String {
        if paused == true {
            return "tempo ativo congelado em \(pausedDisplay ?? "indisponível")"
        }
        return "tempo ativo"
    }

    @ViewBuilder
    var timerText: some View {
        if paused == true || reduceMotion {
            timerTextPausedOrRM
        } else {
            Text(startedAt, style: .timer)
        }
    }

    @ViewBuilder
    var timerTextPausedOrRM: some View {
        if paused == true {
            // Honesty: missing pausedDisplay → em dash, never "0:00"
            Text(FleetWidgetA11y.productElapsedBar(pausedDisplay ?? "—"))
        } else if reduceMotion {
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                Text(AtlasTime.formatActiveDuration(milliseconds: elapsedMs(now: timeline.date)))
            }
        }
    }

    func elapsedMs(now: Date) -> Int {
        Int(max(0, now.timeIntervalSince(startedAt)) * 1000)
    }
}

// MARK: - WidgetsInk

enum Ink {
    static let bg = Color(red: 0x1d / 255.0, green: 0x2b / 255.0, blue: 0x34 / 255.0)
    static let surface = Color(red: 0x24 / 255.0, green: 0x37 / 255.0, blue: 0x43 / 255.0)
    static let ink = Color(red: 0xd6 / 255.0, green: 0xdd / 255.0, blue: 0xe2 / 255.0)
    static let ink2 = Color(red: 0x95 / 255.0, green: 0xa3 / 255.0, blue: 0xac / 255.0)
    static let gold = Color(red: 0xd4 / 255.0, green: 0xa8 / 255.0, blue: 0x5a / 255.0)
    static let alert = Color(red: 0xe0 / 255.0, green: 0x75 / 255.0, blue: 0x5f / 255.0)
    static let healed = Color(red: 0x7f / 255.0, green: 0xb6 / 255.0, blue: 0x8f / 255.0)
}

// MARK: - AtlasWidgets

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
