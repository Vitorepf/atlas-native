import AtlasCore
import Foundation

// Spoken label — peel de CodeWeekWidget+A11y.

extension CodeWeekWidgetA11y {
    static func spokenLabel(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> String {
        var parts: [String]
        if isQuiet(week) {
            parts = ["Semana \(week.window), semana quieta, sem commits nem curas"]
        } else {
            parts = ["Semana \(week.window)"]
            if week.commits > 0 { parts.append("\(week.commits) commit\(week.commits == 1 ? "" : "s")") }
            if week.heals > 0 { parts.append("\(week.heals) cura\(week.heals == 1 ? "" : "s")") }
            if week.prevented > 0 { parts.append("\(week.prevented) prevenido\(week.prevented == 1 ? "" : "s")") }
        }
        if stale { parts.append("visto \(age)") }
        return parts.joined(separator: ", ")
    }
}
