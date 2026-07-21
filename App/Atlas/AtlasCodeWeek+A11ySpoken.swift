import AtlasCore
import Foundation

// Cycle 041 fuse → AtlasCodeWeek+A11ySpoken.swift

extension AtlasCodeWeekUI {
    static func weekPhaseID(_ week: AtlasCodeWeek) -> String {
        if isQuiet(week) { return "quiet-\(week.window)" }
        return "active-\(week.window)-\(week.commits)-\(week.heals)-\(week.prevented)"
    }
}

enum AtlasCodeWeekUISpoken {
    static func spokenLabel(window: String, commits: Int, heals: Int, prevented: Int) -> String {
        AtlasCodeWeekUISpokenQuiet.spokenLabel(
            window: window, commits: commits, heals: heals, prevented: prevented
        )
    }

    static func spokenLabel(_ week: AtlasCodeWeek) -> String {
        spokenLabel(
            window: week.window,
            commits: week.commits,
            heals: week.heals,
            prevented: week.prevented
        )
    }
}
