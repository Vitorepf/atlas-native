import Foundation
import AtlasCore

// Suite measured summary spoken — peel de ArenaSuitesSection+A11y.

extension ArenaSuitesSectionA11y {
    static func spokenMeasuredSummary(count: Int, measured: Int) -> [String] {
        guard count > 0 else { return [] }
        if measured < count {
            return ["\(measured) medidas"]
        }
        if measured > 0 {
            return ["todas medidas"]
        }
        return []
    }
}
