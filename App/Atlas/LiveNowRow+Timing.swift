import SwiftUI
import AtlasCore

/// Relógio, timing e acessibilidade temporal — peel de LiveNowRow.
extension LiveNowRow {
    var timingWord: String {
        switch session.timing {
        case .running: return "em execução"
        case .paused: return "pausado"
        case .finished: return "concluído"
        }
    }

    var timingColor: Color {
        switch session.timing {
        case .running: return AtlasTheme.accent
        case .paused: return AtlasTheme.textTertiary
        case .finished: return AtlasTheme.textSecondary
        }
    }

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
            }
            if session.timing == .paused, let age = pauseAgeHours(now: now) {
                Text("· há \(age)h")
                    .font(AtlasFont.serifItalic(12))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
    }

    @ViewBuilder
    func clockView(now: Date) -> some View {
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

    var a11yLabel: String {
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

    var remoteSuffix: String {
        session.isRemote ? ", sessão remota em outra superfície" : ""
    }

    func isLongPaused(now: Date) -> Bool {
        pauseAgeHours(now: now) != nil
    }

    func pauseAgeHours(now: Date) -> Int? {
        guard session.timing == .paused, let pauseTimestamp = session.pauseTimestamp else { return nil }
        let seconds = max(0, now.timeIntervalSince(pauseTimestamp))
        guard seconds >= 30 * 60 else { return nil }
        return max(1, Int(seconds / 3600))
    }

    /// Relógio canônico: `elapsedActiveMs` + (now − runningSince) quando running.
    /// Paused congela o acumulado. Sem timer do servidor → "—" (ausência ≠ zero).
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
