import Foundation

// MARK: - Types

/// Exclusive Arena run-sheet shell face (WAVE-074).
enum ArenaRunSheetFace: Equatable {
    case emptyEngines
    case emptySuites
    case ready(engines: Int, suites: Int)

    var productWord: String {
        switch self {
        case .emptyEngines: return "empty_engines"
        case .emptySuites: return "empty_suites"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .emptyEngines:
            return "nenhum motor publicado"
        case .emptySuites:
            return "nenhuma suite com adapter"
        case .ready(let engines, let suites):
            let e = engines == 1 ? "1 motor" : "\(engines) motores"
            let s = suites == 1 ? "1 suite instalada" : "\(suites) suites instaladas"
            return "\(e), \(s)"
        }
    }
}

// MARK: - Judgment

/// Pure Arena run-sheet shell grammar — face · spoken · pack.
enum ArenaRunSheetJudgment {

    static let sheetTitle = "rodar medição Arena"
    static let sheetHint =
        "escolhe suites, motor e braços; ator e motivo auditáveis são obrigatórios"
    static let closeLabel = "fechar folha de medição"
    static let closeHint = "volta para a Arena sem enviar"
    static let actorHint = "nome de quem autoriza a medição"
    static let reasonHint = "motivo auditável registrado no ledger"

    static func face(engineCount: Int, suiteCount: Int) -> ArenaRunSheetFace {
        if engineCount <= 0 { return .emptyEngines }
        if suiteCount <= 0 { return .emptySuites }
        return .ready(engines: engineCount, suites: suiteCount)
    }

    static func spokenSheet(face: ArenaRunSheetFace) -> String {
        "\(sheetTitle), \(face.spokenFace)"
    }

    static func spokenEmptyEngines() -> String {
        "nenhum motor publicado pelo servidor, rodar medição indisponível"
    }

    static func spokenEmptySuites() -> String {
        "nenhuma suite com adapter instalado, rodar medição indisponível"
    }

    static func spokenErrorLabel(_ message: String) -> String {
        "erro: \(message)"
    }

    static func packFacts(engineCount: Int, suiteCount: Int) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(engineCount: engineCount, suiteCount: suiteCount)
        facts.append("arena_run_sheet_face: \(face.productWord)")
        facts.append("arena_run_engines: \(engineCount)")
        facts.append("arena_run_suites: \(suiteCount)")
        switch face {
        case .emptyEngines:
            absences.append("sem motores publicados para rodar")
        case .emptySuites:
            absences.append("sem suites com adapter instalado")
        case .ready:
            break
        }
        return (facts, absences)
    }
}
