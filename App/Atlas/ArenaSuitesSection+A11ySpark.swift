import Foundation
import AtlasCore

// Sparkline predicate — peel de ArenaSuitesSection+A11ySuite.

extension ArenaSuitesSectionA11y {
    static func hasSparkline(for suite: AtlasArenaSuite) -> Bool {
        guard let engine = suite.engines.first else { return false }
        return engine.history.contains { $0.score != nil }
    }
}
