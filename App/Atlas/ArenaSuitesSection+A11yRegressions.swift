import Foundation
import AtlasCore

// Suite regression spoken — peel de ArenaSuitesSection+A11y.

extension ArenaSuitesSectionA11y {
    static func spokenRegressionParts(_ suites: [AtlasArenaSuite]) -> [String] {
        let regressions = suites.filter(\.hasRegression).count
        guard regressions > 0 else { return [] }
        let regNoun = regressions == 1 ? "regressão" : "regressões"
        return ["\(regressions) \(regNoun)"]
    }
}
