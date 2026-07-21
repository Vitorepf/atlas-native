import Foundation
import AtlasCore
import SwiftUI

// MARK: - Types

/// Exclusive Arena capabilities list face (WAVE-094).
enum ArenaCapabilitiesFace: Equatable {
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
            return "capacidades ainda não medidas"
        case .list(let n):
            let noun = n == 1 ? "capacidade" : "capacidades"
            return "\(n) \(noun)"
        }
    }
}

/// Attention tone for summary metrics (presentation).
enum ArenaCapabilitiesDeltaTone: Equatable {
    case positive
    case neutral
    case negative
}

// MARK: - Counts (one law)

/// Pure measured/improved/regressed counts — UI ≡ pack (WAVE-094).
/// measured = confidenceLevel.measured only (score presence ≠ measured).
struct ArenaCapabilitiesCounts: Equatable {
    let total: Int
    let measured: Int
    let improved: Int
    let regressed: Int
    let stable: Int

    var unmeasured: Int { max(0, total - measured) }
}

// MARK: - Judgment

/// Pure capabilities confidence grammar — face · counts · rank · spoken · pack.
enum ArenaCapabilitiesJudgment {

    static let emptyTitle = "Capacidades ainda não medidas"
    static let emptyBody = "Ausência permanece ausência — nenhuma barra começa em zero."
    static let coveredLabel = "capacidades cobertas"
    static let groupOrder = ["construction", "comprehension", "quality", "agentic"]

    // MARK: Face / counts

    static func face(_ capabilities: [AtlasArenaCapability]) -> ArenaCapabilitiesFace {
        capabilities.isEmpty ? .empty : .list(capabilities.count)
    }

    static func isMeasured(_ capability: AtlasArenaCapability) -> Bool {
        capability.confidenceLevel == .measured
    }

    static func isSignificantImproved(_ capability: AtlasArenaCapability) -> Bool {
        guard isMeasured(capability),
              capability.delta?.significant == true,
              let value = capability.delta?.value else { return false }
        return value > 0
    }

    static func isSignificantRegressed(_ capability: AtlasArenaCapability) -> Bool {
        guard isMeasured(capability),
              capability.delta?.significant == true,
              let value = capability.delta?.value else { return false }
        return value < 0
    }

    static func counts(of capabilities: [AtlasArenaCapability]) -> ArenaCapabilitiesCounts {
        let measured = capabilities.filter(isMeasured).count
        let improved = capabilities.filter(isSignificantImproved).count
        let regressed = capabilities.filter(isSignificantRegressed).count
        let stable = max(0, measured - improved - regressed)
        return ArenaCapabilitiesCounts(
            total: capabilities.count,
            measured: measured,
            improved: improved,
            regressed: regressed,
            stable: stable
        )
    }

    // MARK: Rank — regressed-first · low confidence · wire-stable

    /// 0 regressed significant · 1 low confidence · 2 unmeasured · 3 measured noise · 4 improved
    static func attentionRank(_ capability: AtlasArenaCapability) -> Int {
        if isSignificantRegressed(capability) { return 0 }
        switch capability.confidenceLevel {
        case .low: return 1
        case .unmeasured: return 2
        case .measured:
            if isSignificantImproved(capability) { return 4 }
            return 3
        }
    }

    static func rank(_ capabilities: [AtlasArenaCapability]) -> [AtlasArenaCapability] {
        capabilities.enumerated().sorted { lhs, rhs in
            let lr = attentionRank(lhs.element)
            let rr = attentionRank(rhs.element)
            if lr != rr { return lr < rr }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func members(
        in group: String,
        capabilities: [AtlasArenaCapability]
    ) -> [AtlasArenaCapability] {
        let filtered = capabilities.filter { ($0.group ?? "quality") == group }
        return rank(filtered)
    }

    // MARK: shortConfidence / spoken / delta chrome

    static func shortConfidence(_ capability: AtlasArenaCapability) -> String? {
        if let gated = capability.gatedReason, !gated.isEmpty {
            return gated
        }
        switch capability.confidenceLevel {
        case .measured:
            return capability.delta?.significant == true ? nil : "dentro do ruído"
        case .low:
            let n = capability.withAtlasCases ?? capability.baselineCases ?? 0
            return "poucos casos (N \(n)) · baixa confiança"
        case .unmeasured:
            if let rate = capability.maxExclusionRate, rate >= 0.5 {
                return "\(Int((rate * 100).rounded()))% descartado no setup · não medível"
            }
            return capability.withAtlas == nil ? "Atlas ainda não rodou aqui" : "não medível"
        }
    }

    static func deltaValue(_ capability: AtlasArenaCapability) -> Double? {
        capability.delta?.value
    }

    static func deltaDisplayText(_ capability: AtlasArenaCapability) -> String {
        capability.confidenceLevel == .unmeasured
            ? "—"
            : ArenaFormat.signed(deltaValue(capability))
    }

    static func deltaTone(_ capability: AtlasArenaCapability) -> ArenaCapabilitiesDeltaTone {
        switch capability.confidenceLevel {
        case .unmeasured, .low:
            return .neutral
        case .measured:
            guard capability.delta?.significant == true, let value = deltaValue(capability) else {
                return .neutral
            }
            return value > 0 ? .positive : .negative
        }
    }

    static func deltaColor(_ capability: AtlasArenaCapability) -> Color {
        switch deltaTone(capability) {
        case .positive: return AtlasTheme.textPrimary
        case .negative: return AtlasTheme.alert
        case .neutral:
            switch capability.confidenceLevel {
            case .unmeasured, .low: return AtlasTheme.textTertiary
            case .measured: return AtlasTheme.textSecondary
            }
        }
    }

    static func spokenRow(_ capability: AtlasArenaCapability) -> String {
        let base = "\(capability.labelPt), sem Atlas \(ArenaFormat.score(capability.score)), com Atlas \(ArenaFormat.score(capability.withAtlas)), diferença \(ArenaFormat.signed(deltaValue(capability)))"
        guard let caption = shortConfidence(capability) else { return base }
        return "\(base), \(caption)"
    }

    static func capabilitiesCaption(engineOptionCount: Int) -> String {
        if engineOptionCount > 1 {
            return "Toque no nome do motor para ver outro perfil medido. Cada capacidade abre as suítes que alimentaram a medida."
        }
        return "Cada capacidade abre as suítes e os casos que contribuíram para a medida."
    }

    // MARK: Pack — never score-presence as “cobertas”

    static func packFacts(
        _ capabilities: [AtlasArenaCapability]
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(capabilities)
        let c = counts(of: capabilities)
        facts.append("capabilities_face: \(face.productWord)")
        facts.append("capabilities_total: \(c.total)")
        facts.append("capabilities_measured: \(c.measured)")
        facts.append("capabilities_improved: \(c.improved)")
        facts.append("capabilities_regressed: \(c.regressed)")
        facts.append("capabilities_stable: \(c.stable)")
        facts.append("capabilities_unmeasured: \(c.unmeasured)")
        // Explicit honesty: score presence is NOT measured coverage.
        let scorePresence = capabilities.filter { $0.score != nil || $0.withAtlas != nil }.count
        if scorePresence != c.measured {
            facts.append("capabilities_score_presence: \(scorePresence) (≠ measured)")
            absences.append("score presence ≠ confidence measured — não vender como cobertas")
        }
        switch face {
        case .empty:
            absences.append("nenhuma capacidade publicada neste motor")
        case .list:
            for cap in rank(capabilities).prefix(8) {
                let conf = cap.confidenceLevel.rawValue
                facts.append(
                    "cap · \(cap.labelPt): conf \(conf) · sem \(ArenaFormat.score(cap.score)) → com \(ArenaFormat.score(cap.withAtlas)) (\(ArenaFormat.signed(deltaValue(cap))))"
                )
            }
        }
        return (facts, absences)
    }
}
