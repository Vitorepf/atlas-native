import Foundation
import AtlasCore

// MARK: - Evolution timeline judgment (WAVE-034)

enum AutonomosEvolutionFace: Equatable {
    case unbound
    case empty
    case items(Int)

    var productWord: String {
        switch self {
        case .unbound: return "unbound"
        case .empty: return "quiet"
        case .items: return "delivered"
        }
    }

    var spokenFace: String {
        switch self {
        case .unbound: return "área de loop não ligada"
        case .empty: return "sem entregas publicadas"
        case .items(let n):
            return n == 1 ? "1 entrega publicada" : "\(n) entregas publicadas"
        }
    }

    var heroSub: String {
        switch self {
        case .unbound:
            return "Sem área registrada selecionada — evolução não inventa marcos."
        case .empty:
            return "Nenhum ciclo merge-proved neste recorte. Silêncio honesto."
        case .items:
            return "Só o que o ledger publicou com prova."
        }
    }
}

struct AutonomosEvolutionMarco: Identifiable, Equatable {
    let cycle: AtlasAutonomosCycle
    let mergeProved: Bool

    var id: String { cycle.id }

    var title: String {
        if mergeProved {
            return "Merge comprovado · ciclo \(cycle.cycleIndex)"
        }
        return "Ciclo \(cycle.cycleIndex) · \(cycle.outcome)"
    }

    var meta: String {
        var parts: [String] = [cycle.cycleFinalStatus]
        if mergeProved, let hash = cycle.mergeHash.nonEmpty {
            parts.append(String(hash.prefix(8)))
        }
        if !cycle.recordedAt.isEmpty {
            parts.append(cycle.recordedAt)
        }
        return parts.joined(separator: " · ")
    }
}

enum AutonomosEvolutionJudgment {

    /// Prefer delivered (merge-scoped) then other published cycles without inventing merges.
    static func marcos(
        delivered: AtlasAutonomosDeliveredResponse?,
        cycles: AtlasAutonomosCyclesResponse?
    ) -> [AutonomosEvolutionMarco] {
        var seen = Set<String>()
        var out: [AutonomosEvolutionMarco] = []

        for cycle in delivered?.delivered ?? [] {
            let key = cycle.id
            guard seen.insert(key).inserted else { continue }
            let proved = cycle.mergePerformed && cycle.mergeHash.nonEmpty != nil
            out.append(AutonomosEvolutionMarco(cycle: cycle, mergeProved: proved))
        }
        for cycle in cycles?.cycles ?? [] {
            let key = cycle.id
            guard seen.insert(key).inserted else { continue }
            let proved = cycle.mergePerformed && cycle.mergeHash.nonEmpty != nil
            // Secondary: history cycles only if not already in delivered.
            out.append(AutonomosEvolutionMarco(cycle: cycle, mergeProved: proved))
        }

        return rank(out)
    }

    /// Merge-proved first, then higher cycleIndex, then recordedAt.
    static func rank(_ items: [AutonomosEvolutionMarco]) -> [AutonomosEvolutionMarco] {
        items.sorted { lhs, rhs in
            if lhs.mergeProved != rhs.mergeProved { return lhs.mergeProved && !rhs.mergeProved }
            if lhs.cycle.cycleIndex != rhs.cycle.cycleIndex {
                return lhs.cycle.cycleIndex > rhs.cycle.cycleIndex
            }
            return lhs.cycle.recordedAt > rhs.cycle.recordedAt
        }
    }

    static func face(
        areaSelected: Bool,
        marcos: [AutonomosEvolutionMarco]
    ) -> AutonomosEvolutionFace {
        if !areaSelected { return .unbound }
        if marcos.isEmpty { return .empty }
        return .items(marcos.count)
    }

    static func mergeProvedCount(_ marcos: [AutonomosEvolutionMarco]) -> Int {
        marcos.filter(\.mergeProved).count
    }

    static func hubEvolutionMeta(marcos: [AutonomosEvolutionMarco], areaSelected: Bool) -> String {
        if !areaSelected { return "área unbound" }
        let n = mergeProvedCount(marcos)
        if n == 0 { return "sem merge-proved" }
        return n == 1 ? "1 entrega" : "\(n) entregas"
    }

    static func packFacts(marcos: [AutonomosEvolutionMarco]) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let proved = mergeProvedCount(marcos)
        facts.append("evolution_marcos: \(marcos.count)")
        facts.append("merge_proved: \(proved)")
        for m in marcos.prefix(5) where m.mergeProved {
            facts.append("entrega: ciclo \(m.cycle.cycleIndex)")
        }
        if marcos.isEmpty {
            absences.append("sem ciclos publicados em delivered/cycles neste recorte")
        }
        return (facts, absences)
    }

    // MARK: Marco spoken (WAVE-104)

    static func spokenMarco(title: String, meta: String) -> String {
        "\(title), \(meta)"
    }

    static func marcoHint(mergeProved: Bool) -> String {
        mergeProved ? "abre o recibo de auto-construção" : ""
    }

}
