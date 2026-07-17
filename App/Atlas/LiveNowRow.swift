import SwiftUI
import AtlasCore

/// Uma linha do Session Hub / VIVO AGORA — title, phase, timing, elapsed.
struct LiveNowRow: View {
    let session: LiveSessionSnapshot
    let hubMode: Bool
    let reduceMotion: Bool
    let remoteBadgeID: String?
    let onTap: () -> Void

    private var navigable: Bool { session.threadId != nil }

    var body: some View {
        Group {
            if navigable {
                Button(action: onTap) { rowContent }
                    .buttonStyle(PressableScale())
            } else {
                rowContent
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(a11yLabel)
        .accessibilityAddTraits(navigable ? .isButton : [])
    }

    private var rowContent: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                BreathingDiamond(
                    size: 8,
                    reduceMotion: reduceMotion || session.timing != .running
                )
                VStack(alignment: .leading, spacing: hubMode ? 4 : 3) {
                    Text(session.title)
                        .font(AtlasFont.serif(16, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .lineLimit(2)
                        .layoutPriority(1)
                    HStack(spacing: 6) {
                        Text(session.phaseTitle)
                            .font(AtlasFont.serifItalic(13))
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .lineLimit(1)
                        if session.isRemote {
                            remoteBadge
                        }
                    }
                    // Timing explícito (running/paused) + elapsed.
                    timingLine(now: context.date)
                }
                Spacer(minLength: 0)
                if navigable {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            .opacity(isLongPaused(now: context.date) ? 0.58 : 1)
        }
    }

    private var remoteBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 8, weight: .semibold))
            Text("remota")
                .font(AtlasFont.mono(9))
                .tracking(0.4)
        }
        .foregroundStyle(AtlasTheme.accent)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Capsule().fill(AtlasTheme.goldVeil))
        .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("sessão remota em outra superfície")
        .accessibilityIdentifier(remoteBadgeID ?? "")
    }
}
