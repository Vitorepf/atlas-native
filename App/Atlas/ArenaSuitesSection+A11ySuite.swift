import Foundation
import AtlasCore

// Spoken suite row — peel de ArenaSuitesSectionA11y.
// Spark → ArenaSuitesSection+A11ySpark.swift
// Measured → ArenaSuitesSection+A11yMeasured.swift

extension ArenaSuitesSectionA11y {
    static func spokenSuite(_ suite: AtlasArenaSuite) -> String {
        var parts = [suite.suite]
        if !suite.adapterInstalled {
            parts.append("sem adapter instalado")
        }
        if suite.hasRegression {
            parts.append("regressão detectada")
        }
        if suite.isMeasured {
            parts.append(contentsOf: spokenMeasuredParts(suite))
        } else {
            parts.append("não medida")
        }
        return parts.joined(separator: ", ")
    }
}
