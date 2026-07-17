import AtlasCore
import Foundation

// Stale suffix — peel de AtlasWidgetAccessories+LiveSession+A11ySpoken.

extension LiveSessionWidgetA11y {
    static func spokenStaleParts(stale: Bool, age: String) -> [String] {
        stale ? ["visto \(age)"] : []
    }
}
