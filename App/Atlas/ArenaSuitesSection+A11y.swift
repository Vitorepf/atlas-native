import Foundation
import AtlasCore

/// Spoken labels — peel de ArenaSuitesSection (CICLO C residual honesty).
/// Lista vazia = silêncio total; score/histórico só com dado publicado.
/// Suite → ArenaSuitesSection+A11ySuite.swift
/// Measured → +A11yMeasuredSummary.swift · Regressions → +A11yRegressions.swift

enum ArenaSuitesSectionA11y {
    static func spokenSection(_ suites: [AtlasArenaSuite]) -> String {
        let count = suites.count
        let measured = suites.filter(\.isMeasured).count
        let noun = count == 1 ? "suite" : "suites"
        var parts = ["\(count) \(noun)"]
        parts.append(contentsOf: spokenMeasuredSummary(count: count, measured: measured))
        parts.append(contentsOf: spokenRegressionParts(suites))
        return parts.joined(separator: ", ")
    }
}
