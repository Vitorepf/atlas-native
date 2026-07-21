import Foundation

// MARK: - Types

/// Exclusive Autônomos catalog list face (WAVE-090).
enum AutonomosListFace: Equatable {
    case empty
    case list(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .list(let n): return "list(\(n))"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "nenhum autônomo ainda"
        case .list(let n):
            let noun = n == 1 ? "autônomo" : "autônomos"
            return "\(n) \(noun)"
        }
    }
}

/// Exclusive catalog row face (WAVE-090).
enum AutonomosListRowFace: Equatable {
    case awaiting
    case live
    case quiet

    var productWord: String {
        switch self {
        case .awaiting: return AutonomosHubVestment.awaiting(1).productWord
        case .live: return AutonomosHubVestment.listFace(unitPaused: false).productWord
        case .quiet: return AutonomosHubVestment.listFace(unitPaused: true).productWord
        }
    }

    var spokenFace: String {
        switch self {
        case .awaiting: return AutonomosHubVestment.awaiting(1).spokenFace
        case .live: return "vivo"
        case .quiet: return AutonomosHubVestment.listFace(unitPaused: true).spokenFace
        }
    }
}

// MARK: - Judgment

/// Pure Autônomos catalog list grammar — list face · row face · rank · spoken · pack.
enum AutonomosListJudgment {

    static let emptyHint = "Abre a folha para definir nome e carta"
    static let emptyBody =
        "Defina um Autônomo com escopo fechado. Por agora o catálogo vive só neste iPhone — some se o app for morto."
    static let emptyFootnote =
        "Create no servidor ainda pendente — sem frota 24/7 inventada."
    static let emptyHero = "Nenhum ainda"
    static let createCTA = "Novo Autônomo"

    // MARK: Face

    static func listFace(unitCount: Int) -> AutonomosListFace {
        unitCount <= 0 ? .empty : .list(unitCount)
    }

    static func rowFace(unitID: String, paused: Bool, awaitingUnitIDs: Set<String>) -> AutonomosListRowFace {
        if awaitingUnitIDs.contains(unitID) { return .awaiting }
        if paused { return .quiet }
        return .live
    }

    static func rowFace(unit: AutonomosUnit, awaitingUnitIDs: Set<String>) -> AutonomosListRowFace {
        rowFace(unitID: unit.id, paused: unit.paused, awaitingUnitIDs: awaitingUnitIDs)
    }

    // MARK: Rank (WAVE-026)

    static func rankUnits(_ units: [AutonomosUnit], awaitingUnitIDs: Set<String>) -> [AutonomosUnit] {
        AutonomosDecisionJudgment.rankUnits(units, awaitingUnitIDs: awaitingUnitIDs)
    }

    // MARK: Spoken

    static func spokenEmpty() -> String {
        "Nenhum Autônomo ainda. Catálogo local neste iPhone; create no servidor pendente."
    }

    static func spokenRow(
        name: String,
        charter: String,
        ageLabel: String,
        rowFace: AutonomosListRowFace
    ) -> String {
        [name, charter, rowFace.spokenFace, ageLabel].joined(separator: ", ")
    }

    static func spokenRow(unit: AutonomosUnit, awaitingUnitIDs: Set<String>) -> String {
        spokenRow(
            name: unit.name,
            charter: unit.charter,
            ageLabel: unit.ageLabel,
            rowFace: rowFace(unit: unit, awaitingUnitIDs: awaitingUnitIDs)
        )
    }

    // MARK: Pack

    static func packFacts(
        units: [AutonomosUnit],
        awaitingUnitIDs: Set<String>
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = listFace(unitCount: units.count)
        facts.append("autonomos_list_face: \(face.productWord)")
        facts.append("autonomos_list_count: \(units.count)")
        facts.append("autonomos_list_awaiting: \(awaitingUnitIDs.count)")
        switch face {
        case .empty:
            absences.append("catálogo Autônomos vazio neste iPhone")
            absences.append("create no servidor ainda pendente (§5)")
        case .list:
            let ranked = rankUnits(units, awaitingUnitIDs: awaitingUnitIDs)
            for unit in ranked.prefix(5) {
                let rf = rowFace(unit: unit, awaitingUnitIDs: awaitingUnitIDs)
                facts.append("autonomos_row: \(unit.name) · \(rf.productWord)")
            }
        }
        return (facts, absences)
    }
}
