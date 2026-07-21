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

    // MARK: Pack identity (WAVE-187)

    /// Graph identity — trunk/head/commits/phase · never invents hashes.
    @MainActor
    static func packIdentityFacts(
        model: AtlasCodeModel
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []

        if let trunk = model.graph?.defaultBranch, !trunk.isEmpty {
            facts.append("graph_trunk: \(trunk)")
        } else {
            absences.append("trunk/default_branch não publicado neste load")
        }
        if let head = model.graph?.head, !head.isEmpty {
            facts.append("graph_head: \(String(head.prefix(7)))")
        }
        if let trunkHead = model.graph?.trunkHead, !trunkHead.isEmpty {
            facts.append("graph_trunk_head: \(String(trunkHead.prefix(7)))")
        }

        let nodes = model.graph?.nodes ?? []
        if !nodes.isEmpty {
            facts.append("graph_commits_loaded: \(nodes.count)")
            let violating = nodes.filter { model.state(for: $0) == .violating }.count
            facts.append("graph_sem_retorno_signals: \(violating)")
        } else {
            absences.append("grafo sem nós (load vazio ou ainda carregando)")
        }

        switch model.phase {
        case .loading, .idle:
            facts.append("graph_phase: loading")
        case .failed(let message):
            facts.append("graph_phase: failed")
            if !message.isEmpty { facts.append("graph_failure: \(message)") }
        case .loaded:
            facts.append("graph_phase: loaded")
        }

        return (facts, absences)
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

    static func spokenRepoTitle(_ repo: String) -> String {
        "repositório \(repo)"
    }

    // MARK: Graph chrome spoken (IDLE · was AtlasCodeGraphA11y)

    static let emptyGraph = "grafo sem commits nesta janela"

    static func spokenStatus(scanState: AtlasCodeScanState, headline: String) -> String {
        switch scanState {
        case .clean, .unknown:
            return headline
        case .violating:
            return "atenção, \(headline)"
        }
    }

    static func spokenFilterChip(
        _ option: AtlasCodeGraphStateFilter,
        count: Int,
        active: Bool,
        silent: Bool
    ) -> String {
        var label = "filtrar grafo por \(option.label), \(count) commits"
        if active { label += ", selecionado" }
        if silent { label += ", nenhum commit neste filtro" }
        return label
    }
}

// MARK: - AtlasCodeWorktreeJudgment

// MARK: - Types

/// Exclusive Código graph worktrees section face (WAVE-087).
enum AtlasCodeWorktreeSectionFace: Equatable {
    case silence
    case list(Int)

    var productWord: String {
        switch self {
        case .silence: return "silence"
        case .list(let n): return "list(\(n))"
        }
    }

    var spokenFace: String {
        switch self {
        case .silence:
            return "nenhum worktree publicado"
        case .list(let n):
            let noun = n == 1 ? "worktree" : "worktrees"
            return "\(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure worktree strip grammar — section face · rank · chip spoken · pack.
enum AtlasCodeWorktreeJudgment {

    // MARK: Face

    static func sectionFace(_ worktrees: [AtlasCodeWorktree]) -> AtlasCodeWorktreeSectionFace {
        if worktrees.isEmpty { return .silence }
        return .list(worktrees.count)
    }

    // MARK: Rank — dirty/active first, path-stable

    /// Lower rank = more attention. Non-clean state first, then non-empty state,
    /// then pathLabel stable.
    static func attentionRank(_ worktree: AtlasCodeWorktree) -> Int {
        guard let state = worktree.state?.trimmingCharacters(in: .whitespacesAndNewlines),
              !state.isEmpty else {
            return 20
        }
        let lower = state.lowercased()
        if lower.contains("dirty") || lower.contains("modified") || lower.contains("conflict") {
            return 0
        }
        if lower.contains("active") || lower.contains("locked") {
            return 5
        }
        if lower == "clean" || lower == "pristine" {
            return 15
        }
        return 10
    }

    static func rank(_ worktrees: [AtlasCodeWorktree]) -> [AtlasCodeWorktree] {
        worktrees.enumerated().sorted { lhs, rhs in
            let lr = attentionRank(lhs.element)
            let rr = attentionRank(rhs.element)
            if lr != rr { return lr < rr }
            let lp = lhs.element.pathLabel
            let rp = rhs.element.pathLabel
            if lp != rp { return lp < rp }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    // MARK: Spoken

    static func spokenChip(_ worktree: AtlasCodeWorktree) -> String {
        var parts = [worktree.pathLabel]
        if let branch = worktree.branch?.nonEmpty {
            parts.append("branch \(branch)")
        }
        if let head = worktree.head?.nonEmpty {
            parts.append(String(head.prefix(8)))
        }
        if let state = worktree.state?.nonEmpty {
            parts.append(state)
        }
        return parts.joined(separator: ", ")
    }

    static func spokenSection(_ worktrees: [AtlasCodeWorktree]) -> String {
        let face = sectionFace(worktrees)
        guard case .list = face else { return face.spokenFace }
        let ranked = rank(worktrees)
        var parts = [face.spokenFace]
        if let head = ranked.first {
            parts.append("primeiro \(spokenChip(head))")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Pack

    static func packFacts(
        _ worktrees: [AtlasCodeWorktree]
    ) -> (facts: [String], absences: [String], anchors: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        var anchors: [String] = []
        let face = sectionFace(worktrees)
        facts.append("worktree_face: \(face.productWord)")
        facts.append("worktrees: \(worktrees.count)")
        switch face {
        case .silence:
            absences.append("worktrees não publicados neste load")
        case .list:
            for wt in rank(worktrees).prefix(5) {
                var line = "worktree: \(wt.pathLabel)"
                if let branch = wt.branch?.nonEmpty { line += " · \(branch)" }
                if let state = wt.state?.nonEmpty { line += " · \(state)" }
                facts.append(line)
                anchors.append(spokenChip(wt))
            }
        }
        return (facts, absences, anchors)
    }
}

// MARK: - AtlasCodeGraphLoadJudgment

// MARK: - Types

/// Exclusive código graph-screen face (WAVE-061).
enum AtlasCodeGraphScreenFace: Equatable {
    case loading
    case failed(String?)
    case empty
    case ready(Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "carregando"
        case .failed(let message):
            if let message, !message.isEmpty {
                return "falha ao carregar, \(message)"
            }
            return "falha ao carregar"
        case .empty:
            return "sem commits neste recorte"
        case .ready(let n):
            return n == 1 ? "1 commit" : "\(n) commits"
        }
    }
}

// MARK: - Judgment

/// Pure graph-screen load grammar — face · spoken · pack.
enum AtlasCodeGraphLoadJudgment {

    static func face(
        phase: LoadPhase,
        nodeCount: Int,
        failMessage: String? = nil
    ) -> AtlasCodeGraphScreenFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed(let message):
            let published = failMessage ?? message
            return .failed(published.isEmpty ? nil : published)
        case .loaded:
            if nodeCount <= 0 { return .empty }
            return .ready(nodeCount)
        }
    }

    /// Screen spoken: "grafo, {repo}, {face spoken}".
    static func spokenScreen(repo: String, face: AtlasCodeGraphScreenFace) -> String {
        "grafo, \(repo), \(face.spokenFace)"
    }

    static func spokenScreen(
        repo: String,
        phase: LoadPhase,
        nodeCount: Int,
        failMessage: String? = nil
    ) -> String {
        spokenScreen(
            repo: repo,
            face: face(phase: phase, nodeCount: nodeCount, failMessage: failMessage)
        )
    }

    static func packFacts(
        repo: String,
        phase: LoadPhase,
        nodeCount: Int,
        failMessage: String? = nil,
        isAnchoring: Bool = false
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(phase: phase, nodeCount: nodeCount, failMessage: failMessage)
        facts.append("graph_screen_face: \(face.productWord)")
        facts.append("graph_repo: \(repo)")
        switch face {
        case .loading:
            absences.append("grafo ainda carregando")
        case .failed(let msg):
            absences.append("grafo falhou ao carregar")
            if let msg, !msg.isEmpty { facts.append("graph_error: \(msg)") }
        case .empty:
            absences.append("sem commits neste recorte do grafo")
            facts.append("graph_nodes: 0")
        case .ready(let n):
            facts.append("graph_nodes: \(n)")
        }
        if isAnchoring {
            facts.append("graph_anchoring: true")
        }
        return (facts, absences)
    }
}
