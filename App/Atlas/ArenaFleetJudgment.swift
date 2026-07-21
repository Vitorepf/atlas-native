import Foundation
import AtlasCore

// MARK: - Types

/// WAVE-157: fleet rank one law — pack ≡ FleetView “onde o Atlas sobe”.
enum ArenaFleetJudgment {

    // MARK: Rank

    /// Multiplier desc first; then composite desc; then engine id.
    static func rank(_ engines: [AtlasArenaCompositeEngine]) -> [AtlasArenaCompositeEngine] {
        engines.sorted { lhs, rhs in
            switch (lhs.atlasMultiplier, rhs.atlasMultiplier) {
            case let (l?, r?): return l > r
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil):
                switch (lhs.composite, rhs.composite) {
                case let (l?, r?): return l > r
                case (_?, nil): return true
                case (nil, _?): return false
                default: return lhs.engine < rhs.engine
                }
            }
        }
    }

    /// Best gain: first ranked with positive multiplier, else first with composite.
    static func best(in engines: [AtlasArenaCompositeEngine]) -> AtlasArenaCompositeEngine? {
        let ranked = rank(engines)
        return ranked.first { $0.atlasMultiplier != nil && ($0.atlasMultiplier ?? 0) > 0 }
            ?? ranked.first { $0.composite != nil }
    }

    // MARK: Pack

    static func packFacts(
        engines: [AtlasArenaCompositeEngine],
        limit: Int = 8
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let ranked = rank(engines)
        facts.append("frota_motores: \(ranked.count)")
        if ranked.isEmpty {
            absences.append("nenhum motor medido na frota")
            return (facts, absences)
        }
        if let best = best(in: ranked), let mult = best.atlasMultiplier {
            facts.append(
                "frota_melhor: \(ArenaDisplay.engine(best.engine)) · \(ArenaFormat.multiplier(mult))"
            )
        } else {
            absences.append("sem multiplicador positivo publicado na frota")
        }
        for engine in ranked.prefix(limit) {
            let mult = engine.atlasMultiplier.map(ArenaFormat.multiplier) ?? "não medido"
            facts.append(
                "frota · \(ArenaDisplay.engine(engine.engine)): \(mult) (sem \(ArenaFormat.score(engine.withoutAtlasComposite)) → com \(ArenaFormat.score(engine.withAtlasComposite)))"
            )
        }
        return (facts, absences)
    }
}
