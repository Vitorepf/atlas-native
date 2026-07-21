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
                        HStack(spacing: 6) {
                            Text(session.phaseTitle)
                                .font(AtlasFont.serifItalic(13))
                                .foregroundStyle(AtlasTheme.textSecondary)
                                .lineLimit(1)
                            if session.isRemote {
                                remoteBadge
                            }
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
        .accessibilityLabel("sessão remota em outra superfície")
        .accessibilityIdentifier(remoteBadgeID ?? "")
    }
}

extension LiveNowRow {
    var remoteSuffix: String {
        session.isRemote ? ", remota em outra superfície" : ""
    }

    func hubPositionPrefix(index: Int?, count: Int?) -> String {
        guard let index, let count, count >= 2 else { return "" }
        return "sessão \(index + 1) de \(count), "
    }

    func hasMeasurableClock(now: Date) -> Bool {
        session.elapsedActiveMs != nil
    }

    func spokenClock(now: Date) -> String? {
        guard hasMeasurableClock(now: now) else { return nil }
        return Self.formatClock(
            elapsedMs: session.elapsedActiveMs,
            runningSince: session.runningSince,
            now: now,
            paused: session.timing == .paused
        )
    }

    func spokenLabel(hubIndex: Int?, hubCount: Int?, now: Date = .now) -> String {
        let prefix = hubPositionPrefix(index: hubIndex, count: hubCount)
        return spokenActiveLabel(prefix: prefix, now: now)
            ?? spokenFinishedLabel(prefix: prefix)
    }

    func spokenActiveLabel(prefix: String, now: Date) -> String? {
        switch session.timing {
        case .running:
            return spokenRunningLabel(prefix: prefix, now: now)
        case .paused:
            return spokenPausedLabel(prefix: prefix, now: now)
        default:
            return nil
        }
    }

    func spokenRunningLabel(prefix: String, now: Date) -> String {
        // WAVE-023: same face words as ribbon/strip.
        let faceWord = ConversationExecutionPhase.spokenFace(.running)
        if let clock = spokenClock(now: now) {
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), \(faceWord) há \(clock)"
        }
        return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), \(faceWord), tempo ativo indisponível"
    }

    func spokenPausedLabel(prefix: String, now: Date) -> String {
        let faceWord = ConversationExecutionPhase.spokenFace(.paused)
        let age = pauseAgeHours(now: now).map { ", há \($0) horas" } ?? ""
        if let clock = spokenClock(now: now) {
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), \(faceWord) em \(clock)\(age)"
        }
        return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), \(faceWord), tempo ativo indisponível\(age)"
    }

    func spokenFinishedLabel(prefix: String) -> String {
        let faceWord = ConversationExecutionPhase.spokenFace(.finished)
        return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), \(faceWord)"
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
        // WAVE-023 product face words (visual ≡ spoken vocabulary).
        ConversationExecutionPhase.spokenFace(ConversationExecutionPhase.face(for: session))
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
        guard let clock = spokenClock(now: now) else {
            return "tempo ativo indisponível"
        }
        return session.timing == .paused
            ? "tempo ativo congelado em \(clock)"
            : "tempo ativo \(clock)"
    }

    func pauseAgeHours(now: Date) -> Int? {
        guard session.timing == .paused, let pauseTimestamp = session.pauseTimestamp else { return nil }
        let seconds = max(0, now.timeIntervalSince(pauseTimestamp))
        guard seconds >= 30 * 60 else { return nil }
        return max(1, Int(seconds / 3600))
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
        guard let base = elapsedMs else { return "—" }
        var ms = base
        if !paused, let since = runningSince {
            ms += max(0, Int(now.timeIntervalSince(since) * 1000))
        }
        let s = ms / 1000
        return s >= 3600
            ? String(format: "%d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
            : String(format: "%d:%02d", s / 60, s % 60)
    }
}
