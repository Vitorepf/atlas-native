import SwiftUI
import AtlasCore

/// Relógio canônico e pausa longa — peel de `LiveNowRow+Timing`.
extension LiveNowRow {
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
