import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

struct LiveNowRow: View {
    let session: LiveSessionSnapshot
    let hubMode: Bool
    let hubIndex: Int?
    let hubCount: Int?
    let reduceMotion: Bool
    let remoteBadgeID: String?
    let onTap: () -> Void

    var navigable: Bool { session.threadId != nil }

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
        .accessibilityLabel(spokenLabel(hubIndex: hubIndex, hubCount: hubCount))
        .accessibilityHint(navigable ? "abre conversa desta sessão" : "")
        .accessibilityAddTraits(navigable ? .isButton : [])
    }

    var rowContent: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            HStack(alignment: .firstTextBaseline, spacing: 10) {
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
                        // WAVE-027: face spoken is the lead; phaseTitle is detail only.
                        HStack(spacing: 6) {
                            Text(ConversationExecutionPhase.primarySpoken(
                                ConversationExecutionPhase.face(for: session)
                            ))
                            .font(AtlasFont.mono(12, .semibold))
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .lineLimit(1)
                            if session.isRemote {
                                remoteBadge
                            }
                        }
                        if !session.phaseTitle.isEmpty {
                            Text(session.phaseTitle)
                                .font(AtlasFont.serifItalic(12))
                                .foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(1)
                        }
                        timingLine(now: context.date)
                    }
                }
                Spacer(minLength: 0)
                if navigable {
                    Image(systemName: "chevron.right")
                        .atlasSans(12, .semibold)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            .opacity(isLongPaused(now: context.date) ? 0.58 : 1)
        }
    }

    var remoteBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.triangle.branch")
                .atlasSans(8, .semibold)
                .accessibilityHidden(true)
            Text("remota")
                .font(AtlasFont.mono(9))
                .tracking(0.4)
                .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.accent)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Capsule().fill(AtlasTheme.goldVeil))
        .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(LiveNowJudgment.remoteSurfaceBadgeLabel)
        .accessibilityIdentifier(remoteBadgeID ?? "")
    }
}

extension LiveNowRow {
    // WAVE-110: row spoken → LiveNowJudgment

    func spokenClock(now: Date) -> String? {
        LiveNowJudgment.spokenClock(for: session, now: now)
    }

    func spokenLabel(hubIndex: Int?, hubCount: Int?, now: Date = .now) -> String {
        LiveNowJudgment.spokenRow(
            session: session,
            hubIndex: hubIndex,
            hubCount: hubCount,
            now: now
        )
    }

    func pauseAgeHours(now: Date) -> Int? {
        LiveNowJudgment.pauseAgeHours(for: session, now: now)
    }
}

extension LiveNowRow {
    func timingLine(now: Date) -> some View {
        HStack(spacing: 6) {
            Text(timingWord)
                .font(AtlasFont.mono(10))
                .tracking(0.3)
                .foregroundStyle(timingColor)
            if session.timing != .finished {
                Text("·")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                clockView(now: now)
                    .accessibilityLabel(clockAccessibilityLabel(now: now))
            }
            if session.timing == .paused, let age = pauseAgeHours(now: now) {
                Text("· há \(age)h")
                    .font(AtlasFont.serifItalic(12))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
    }

    var timingWord: String {
        // WAVE-027 product mono line (same vocabulary as strip/card).
        ConversationExecutionPhase.primaryProduct(
            ConversationExecutionPhase.face(for: session)
        )
    }

    var timingColor: Color {
        switch session.timing {
        case .running: return AtlasTheme.accent
        case .paused: return AtlasTheme.textTertiary
        case .finished: return AtlasTheme.textSecondary
        }
    }

    @ViewBuilder
    func clockView(now: Date) -> some View {
        switch session.timing {
        case .running:
            TimelineView(.periodic(from: .now, by: reduceMotion ? 60 : 1)) { context in
                clockText(Self.formatClock(
                    elapsedMs: session.elapsedActiveMs,
                    runningSince: session.runningSince,
                    now: context.date,
                    paused: false
                ))
            }
        case .paused:
            clockText(Self.formatClock(
                elapsedMs: session.elapsedActiveMs,
                runningSince: nil,
                now: now,
                paused: true
            ))
        case .finished:
            EmptyView()
        }
    }

    func clockText(_ value: String) -> some View {
        Text(value)
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textSecondary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
    }

    func clockAccessibilityLabel(now: Date) -> String {
        LiveNowJudgment.spokenClockAccessibility(session: session, now: now)
    }

    func isLongPaused(now: Date) -> Bool {
        pauseAgeHours(now: now) != nil
    }

    static func formatClock(
        elapsedMs: Int?,
        runningSince: Date?,
        now: Date,
        paused: Bool
    ) -> String {
        LiveNowJudgment.formatClock(
            elapsedMs: elapsedMs,
            runningSince: runningSince,
            now: now,
            paused: paused
        )
    }
}
