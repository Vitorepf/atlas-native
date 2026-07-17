import AtlasCore
import Foundation

/// Spoken labels do widget Semana — peel de CodeWeekWidgetView (CICLO C residual).

enum CodeWeekWidgetA11y {
    static func isQuiet(_ week: AtlasNativeSnapshot.Week) -> Bool {
        week.commits == 0 && week.heals == 0 && week.prevented == 0
    }

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
