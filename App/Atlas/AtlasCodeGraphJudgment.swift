import Foundation
import AtlasCore

// MARK: - Graph judgment (WAVE-028)

/// Pure commit-map judgment for single-repo grafo — parity organ with RadarJudgment.
/// Casca only; never invents dual-count or agent filter DTOs.
enum AtlasCodeGraphJudgment {

    // MARK: Default attention slice

    /// First-load attention: **fora** when violating signals exist; honest all/unknown otherwise.
    /// Operator chip override is owned by the host (`graphFilterTouchedByOperator`).
    static func defaultFilter(
        scan: AtlasCodeScanState,
        violatingSignalCount: Int
    ) -> AtlasCodeGraphStateFilter {
        switch scan {
        case .violating where violatingSignalCount > 0:
            return .violating
        case .clean, .unknown, .violating:
            return .all
        }
    }

    // MARK: Product words (align chips / spoken)

    static func productWord(for filter: AtlasCodeGraphStateFilter) -> String {
        filter.label // todos | main | fora | curados
    }

    static func productWord(for state: AtlasCodeNodeState) -> String {
        switch state {
        case .onMain: return "main"
        case .violating: return "fora"
        case .healed: return "curados"
        case .history: return "história"
        }
    }

    // MARK: Within-slice attention rank

    /// Severe-first inside current slice when scan is violating; else stable wire order.
    @MainActor
    static func rankNodes(
        _ nodes: [AtlasCodeGraphNode],
        model: AtlasCodeModel,
        scan: AtlasCodeScanState
    ) -> [AtlasCodeGraphNode] {
        guard scan == .violating else { return nodes }
        return nodes.enumerated().sorted { lhs, rhs in
            let ls = model.state(for: lhs.element)
            let rs = model.state(for: rhs.element)
            let lSevere = ls == .violating
            let rSevere = rs == .violating
            if lSevere != rSevere { return lSevere && !rSevere }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    // MARK: Pack slice facts

    @MainActor
    static func packSliceFacts(
        model: AtlasCodeModel,
        filter: AtlasCodeGraphStateFilter
    ) -> (facts: [String], absences: [String], subjectSuffix: String) {
        var facts: [String] = []
        var absences: [String] = []

        facts.append("filter: \(productWord(for: filter))")
        facts.append("status: \(model.statusHeadline)")
        facts.append("scan: \(scanWord(model.scanState))")

        // WAVE-087: worktree face · ranked anchors (not wire dump).
        let wtPack = AtlasCodeWorktreeJudgment.packFacts(model.graph?.worktrees ?? [])
        facts.append(contentsOf: wtPack.facts)
        absences.append(contentsOf: wtPack.absences)

        let nodes = model.graph?.nodes ?? []
        if !nodes.isEmpty {
            let sliceCount = filter.count(in: nodes, model: model)
            facts.append("slice_commits: \(sliceCount)")
        }

        return (facts, absences, productWord(for: filter))
    }

    static func scanWord(_ scan: AtlasCodeScanState) -> String {
        switch scan {
        case .clean: return "clean"
        case .violating: return "violating"
        case .unknown: return "unknown"
        }
    }

    /// can_do: heal face CTA exists → local face only; never claim NL cure write.
    static func packCanDo(hasHealReceipt: Bool) -> AgenticOccasionPack.CanDo {
        hasHealReceipt ? .faceCTALocal : .readChat
    }

    static func packCanDoAbsences(hasHealReceipt: Bool) -> [String] {
        if hasHealReceipt {
            return ["cura NL via chat não autorizada — use o recibo/CTA da face (não invente mandar-curar)"]
        }
        return []
    }
}
