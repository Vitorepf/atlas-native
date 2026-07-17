import AtlasCore
import Foundation

/// Semana no grafo — peel de AtlasCodeGraphChrome+Week (CICLO C residual honesty).
/// Zeros quietos; métricas faladas só quando o servidor publicou valor positivo.
/// Spoken → AtlasCodeWeek+A11ySpoken.swift
/// Phase → AtlasCodeWeek+A11yPhase.swift

enum AtlasCodeWeekUI {
    static func isQuiet(commits: Int, heals: Int, prevented: Int) -> Bool {
        commits == 0 && heals == 0 && prevented == 0
    }

    static func isQuiet(_ week: AtlasCodeWeek) -> Bool {
        isQuiet(commits: week.commits, heals: week.heals, prevented: week.prevented)
    }

    static func spokenLabel(window: String, commits: Int, heals: Int, prevented: Int) -> String {
        AtlasCodeWeekUISpoken.spokenLabel(window: window, commits: commits, heals: heals, prevented: prevented)
    }

    static func spokenLabel(_ week: AtlasCodeWeek) -> String {
        AtlasCodeWeekUISpoken.spokenLabel(week)
    }
}
