import AtlasCore
import Foundation

/// Week phase ID — peel de AtlasCodeWeek+A11y.

extension AtlasCodeWeekUI {
    static func weekPhaseID(_ week: AtlasCodeWeek) -> String {
        if isQuiet(week) { return "quiet-\(week.window)" }
        return "active-\(week.window)-\(week.commits)-\(week.heals)-\(week.prevented)"
    }
}
