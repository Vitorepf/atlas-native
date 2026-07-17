import AtlasCore
import Foundation

/// Quiet week spoken — peel de AtlasCodeWeek+A11ySpoken.

enum AtlasCodeWeekUISpokenQuiet {
    static func spokenLabel(window: String, commits: Int, heals: Int, prevented: Int) -> String {
        if AtlasCodeWeekUI.isQuiet(commits: commits, heals: heals, prevented: prevented) {
            return "A semana \(window), semana quieta, sem commits nem curas"
        }
        var parts = ["A semana \(window)"]
        if commits > 0 { parts.append("\(commits) commit\(commits == 1 ? "" : "s")") }
        if heals > 0 { parts.append("\(heals) cura\(heals == 1 ? "" : "s")") }
        if prevented > 0 { parts.append("\(prevented) prevenida\(prevented == 1 ? "" : "s")") }
        return parts.joined(separator: ", ")
    }
}
