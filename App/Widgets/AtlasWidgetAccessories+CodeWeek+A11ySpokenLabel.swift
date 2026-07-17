import AtlasCore
import Foundation

// Spoken label — peel de CodeWeekWidget+A11y.
// Quiet → AtlasWidgetAccessories+CodeWeek+A11ySpokenLabel+Quiet.swift
// Active → AtlasWidgetAccessories+CodeWeek+A11ySpokenLabel+Active.swift

extension CodeWeekWidgetA11y {
    static func spokenLabel(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> String {
        var parts = isQuiet(week)
            ? spokenQuietWeekParts(week)
            : spokenActiveWeekParts(week)
        if stale { parts.append("visto \(age)") }
        return parts.joined(separator: ", ")
    }
}
