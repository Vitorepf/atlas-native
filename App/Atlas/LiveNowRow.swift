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

    private var timingWord: String {
        switch session.timing {
        case .running: return "em execução"
        case .paused: return "pausado"
        case .finished: return "concluído"
        }
    }

    private var timingColor: Color {
        switch session.timing {
        case .running: return AtlasTheme.accent
        case .paused: return AtlasTheme.textTertiary
        case .finished: return AtlasTheme.textSecondary
        }
    }

    private func timingLine(now: Date) -> some View {
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
            }
            if session.timing == .paused, let age = pauseAgeHours(now: now) {
                Text("· há \(age)h")
                    .font(AtlasFont.serifItalic(12))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
    }

    @ViewBuilder
    private func clockView(now: Date) -> some View {
        switch session.timing {
        case .running:
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(Self.formatClock(
                    elapsedMs: session.elapsedActiveMs,
                    runningSince: session.runningSince,
                    now: context.date,
                    paused: false
                ))
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
            }
        case .paused:
            Text(Self.formatClock(
                elapsedMs: session.elapsedActiveMs,
                runningSince: nil,
                now: now,
                paused: true
            ))
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textSecondary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
        case .finished:
            EmptyView()
        }
    }

    private var a11yLabel: String {
        let clock = Self.formatClock(
            elapsedMs: session.elapsedActiveMs,
            runningSince: session.runningSince,
            now: .now,
            paused: session.timing == .paused
        )
        switch session.timing {
        case .running:
            return "\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução há \(clock)"
        case .paused:
            let age = pauseAgeHours(now: .now).map { ", há \($0) horas" } ?? ""
            return "\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado em \(clock)\(age)"
        case .finished:
            return "\(session.title)\(remoteSuffix), concluído"
        }
    }

    private var remoteSuffix: String {
        session.isRemote ? ", sessão remota em outra superfície" : ""
    }

    private func isLongPaused(now: Date) -> Bool {
        pauseAgeHours(now: now) != nil
    }

    private func pauseAgeHours(now: Date) -> Int? {
        guard session.timing == .paused, let pauseTimestamp = session.pauseTimestamp else { return nil }
        let seconds = max(0, now.timeIntervalSince(pauseTimestamp))
        guard seconds >= 30 * 60 else { return nil }
        return max(1, Int(seconds / 3600))
    }

    /// Relógio canônico: `elapsedActiveMs` + (now − runningSince) quando running.
    /// Paused congela o acumulado. Sem timer do servidor → "—" (ausência ≠ zero).
    private static func formatClock(
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

/// Numeric text morph só quando Reduce Motion está desligado.
private struct NumericTextTransition: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.contentTransition(.numericText())
        } else {
            content
        }
    }
}
