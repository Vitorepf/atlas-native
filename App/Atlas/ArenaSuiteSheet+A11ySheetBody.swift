import Foundation
import AtlasCore

// Sheet body spoken — peel de ArenaSuiteSheet+A11y.

extension ArenaSuiteSheetA11y {
    static func spokenSheet(_ suite: AtlasArenaSuite) -> String {
        let n = suite.engines.count
        if n == 0 {
            return "suite \(suite.suite), nenhum motor neste recorte"
        }
        return "suite \(suite.suite), \(n) motor\(n == 1 ? "" : "es")"
    }
}
