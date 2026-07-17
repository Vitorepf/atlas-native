import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

struct LockScreenView: View {
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
                    // M87 / E-A5: fila N como cápsula gold distinta no título
                    // (não só no HStack mono de progresso).
                    if let queued = context.state.queueLabel {
                        Text(queued)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(Ink.gold)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Capsule().fill(Ink.gold.opacity(0.22)))
                            .overlay(Capsule().stroke(Ink.gold.opacity(0.45), lineWidth: 0.5))
                            .accessibilityLabel(queued)
                    }
                }
                HStack(spacing: 6) {
                    if let badge = context.state.phaseBadge {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Ink.alert)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Ink.alert.opacity(0.16)))
                            .accessibilityLabel(context.state.phaseTitle)
                    }
                    Text(context.state.phaseTitle)
                        .font(.system(size: 13, design: .serif)).italic()
                        .foregroundStyle(context.state.finished ? Ink.healed : context.state.atlasColor.opacity(0.88))
                        .lineLimit(1)
                }
                if let progress = context.state.progressLabel {
                    Text(progress)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Ink.ink2)
                }
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
