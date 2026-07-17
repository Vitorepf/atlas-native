import AtlasCore
import Foundation

// Quiet predicate — peel de CodeWeekWidget+A11y.

extension CodeWeekWidgetA11y {
    static func isQuiet(_ week: AtlasNativeSnapshot.Week) -> Bool {
        week.commits == 0 && week.heals == 0 && week.prevented == 0
    }
}
