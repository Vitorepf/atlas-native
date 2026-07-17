import Foundation
import AtlasCore

// Spoken labels — peel de ArenaSuiteSheet (CICLO C residual honesty).
// Casos/duração só quando o servidor publica; zero «0» fabricado.
// Captions → ArenaSuiteSheet+A11yCaptions.swift
// Engine → ArenaSuiteSheet+A11yEngine.swift

enum ArenaSuiteSheetA11y {
    static func spokenSuiteTitle(_ suite: String) -> String {
        "suite \(suite)"
    }

    static let closeLabel = "fechar detalhes da suite"
    static let closeHint = "volta para a Arena"

    static func spokenSheet(_ suite: AtlasArenaSuite) -> String {
        let n = suite.engines.count
        if n == 0 {
            return "suite \(suite.suite), nenhum motor neste recorte"
        }
        return "suite \(suite.suite), \(n) motor\(n == 1 ? "" : "es")"
    }

    static let sheetHint = "scores, casos e duração só quando o servidor publica"
}
