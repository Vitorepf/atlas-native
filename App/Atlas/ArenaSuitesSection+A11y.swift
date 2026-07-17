import Foundation
import AtlasCore

/// Spoken labels — peel de ArenaSuitesSection (CICLO C residual honesty).
/// Lista vazia = silêncio total; score/histórico só com dado publicado.
/// Suite → ArenaSuitesSection+A11ySuite.swift

enum ArenaSuitesSectionA11y {
    static func spokenSection(_ suites: [AtlasArenaSuite]) -> String {
        let count = suites.count
        let measured = suites.filter(\.isMeasured).count
        let regressions = suites.filter(\.hasRegression).count
        let noun = count == 1 ? "suite" : "suites"
        var parts = ["\(count) \(noun)"]
        if measured < count {
            parts.append("\(measured) medidas")
        } else if measured > 0 {
            parts.append("todas medidas")
        }
        if regressions > 0 {
            let regNoun = regressions == 1 ? "regressão" : "regressões"
            parts.append("\(regressions) \(regNoun)")
        }
        return parts.joined(separator: ", ")
    }
}
