import AtlasCore
import Foundation

/// Spoken week label — peel de AtlasCodeWeek+A11y.
/// Quiet → AtlasCodeWeek+A11ySpokenQuiet.swift

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
