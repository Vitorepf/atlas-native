import AtlasCore
import Foundation

// Active week metrics spoken — peel de CodeWeek A11ySpokenLabel.

extension CodeWeekWidgetA11y {
    static func spokenActiveWeekParts(_ week: AtlasNativeSnapshot.Week) -> [String] {
        var parts = ["Semana \(week.window)"]
        if week.commits > 0 { parts.append("\(week.commits) commit\(week.commits == 1 ? "" : "s")") }
        if week.heals > 0 { parts.append("\(week.heals) cura\(week.heals == 1 ? "" : "s")") }
        if week.prevented > 0 { parts.append("\(week.prevented) prevenido\(week.prevented == 1 ? "" : "s")") }
        return parts
    }
}
