import AtlasCore
import Foundation

// Quiet week spoken — peel de CodeWeek A11ySpokenLabel.

extension CodeWeekWidgetA11y {
    static func spokenQuietWeekParts(_ week: AtlasNativeSnapshot.Week) -> [String] {
        ["Semana \(week.window), semana quieta, sem commits nem curas"]
    }
}
