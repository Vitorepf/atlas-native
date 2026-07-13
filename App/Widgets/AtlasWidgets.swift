import WidgetKit
import SwiftUI
import ActivityKit

// Live Activity do Atlas — a tela bloqueada e a Dynamic Island mostram o
// turno VIVO (paridade Cursor, identidade Ink & Brass). Self-contained: a
// extension não linka AtlasCore nem o design system do app; a paleta mínima
// vive aqui e a serif é a do sistema (.fontDesign(.serif)).

private enum Ink {
    static let bg = Color(red: 0x1d / 255.0, green: 0x2b / 255.0, blue: 0x34 / 255.0)
    static let surface = Color(red: 0x24 / 255.0, green: 0x37 / 255.0, blue: 0x43 / 255.0)
    static let ink = Color(red: 0xd6 / 255.0, green: 0xdd / 255.0, blue: 0xe2 / 255.0)
    static let ink2 = Color(red: 0x95 / 255.0, green: 0xa3 / 255.0, blue: 0xac / 255.0)
    static let gold = Color(red: 0xd4 / 255.0, green: 0xa8 / 255.0, blue: 0x5a / 255.0)
}

@main
struct AtlasWidgetsBundle: WidgetBundle {
    var body: some Widget {
        AtlasTurnLiveActivity()
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
                            .foregroundStyle(Ink.gold)
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
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.finished {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Ink.gold).padding(.trailing, 6)
                    } else {
                        Text(context.state.startedAt, style: .timer)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(Ink.ink2)
                            .frame(width: 44).padding(.trailing, 6)
                    }
                }
            } compactLeading: {
                if context.state.activeSessions > 1 {
                    Text("✦\(context.state.activeSessions)")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundStyle(Ink.gold)
                } else {
                    Text("✦")
                        .font(.system(size: 15, design: .serif))
                        .foregroundStyle(Ink.gold)
                }
            } compactTrailing: {
                if context.state.finished {
                    Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Ink.gold)
                } else {
                    Text(context.state.startedAt, style: .timer)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Ink.ink2).frame(width: 40)
                }
            } minimal: {
                Text("✦").font(.system(size: 14, design: .serif)).foregroundStyle(Ink.gold)
            }
            .keylineTint(Ink.gold)
            .widgetURL(URL(string: "atlas://execution/\(context.attributes.threadKey)"))
        }
    }
}

private struct LockScreenView: View {
    let context: ActivityViewContext<AtlasTurnAttributes>

    var body: some View {
        HStack(spacing: 14) {
            Text("✦")
                .font(.system(size: 28, design: .serif))
                .foregroundStyle(Ink.gold)
                .shadow(color: Ink.gold.opacity(0.35), radius: 4)
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
                    .foregroundStyle(context.state.finished ? Ink.gold : Ink.ink2)
                    .lineLimit(1)
            }
            Spacer()
            if context.state.finished {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22)).foregroundStyle(Ink.gold)
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
