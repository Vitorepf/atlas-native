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
                titleBadges
                phaseLine
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
            } else {
                AtlasTurnWidgetTimer(
                    startedAt: context.state.startedAt,
                    paused: context.state.paused,
                    pausedDisplay: context.state.pausedDisplay,
                    fontSize: 15,
                    frameWidth: 52
                )
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 14)
    }
}
