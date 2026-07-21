import AtlasCore
import Foundation

/// Semana no grafo — peel de AtlasCodeGraphChrome+Week (CICLO C residual honesty).
/// Quiet → AtlasCodeWeek+A11y+Quiet.swift
/// Spoken → AtlasCodeWeek+A11ySpoken.swift
/// Phase → AtlasCodeWeek+A11yPhase.swift

enum AtlasCodeWeekUI {
    static func spokenLabel(window: String, commits: Int, heals: Int, prevented: Int) -> String {
        AtlasCodeWeekUISpoken.spokenLabel(window: window, commits: commits, heals: heals, prevented: prevented)
    }

    static func spokenLabel(_ week: AtlasCodeWeek) -> String {
        AtlasCodeWeekUISpoken.spokenLabel(week)
    }
}
