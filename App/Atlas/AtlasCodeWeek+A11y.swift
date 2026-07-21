import AtlasCore
import Foundation

// Cycle 041 fuse → AtlasCodeWeek+A11y.swift

extension AtlasCodeWeekUI {
    static func isQuiet(commits: Int, heals: Int, prevented: Int) -> Bool {
        commits == 0 && heals == 0 && prevented == 0
    }

    static func isQuiet(_ week: AtlasCodeWeek) -> Bool {
        isQuiet(commits: week.commits, heals: week.heals, prevented: week.prevented)
    }
}

enum AtlasCodeWeekUI {
    static func spokenLabel(window: String, commits: Int, heals: Int, prevented: Int) -> String {
        AtlasCodeWeekUISpoken.spokenLabel(window: window, commits: commits, heals: heals, prevented: prevented)
    }

    static func spokenLabel(_ week: AtlasCodeWeek) -> String {
        AtlasCodeWeekUISpoken.spokenLabel(week)
    }
}
