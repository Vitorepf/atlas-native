import Foundation
import AtlasCore

// Section count noun — peel de ArenaSuitesSection+A11y.

extension ArenaSuitesSectionA11y {
    static func spokenSectionCount(_ count: Int) -> String {
        let noun = count == 1 ? "suite" : "suites"
        return "\(count) \(noun)"
    }
}
