import AtlasCore
import Observation

// IDLE-COMPRESS AtlasCodeModel fused

// --- AtlasCodeModel+State.swift ---
extension AtlasCodeModel {

    func matches(_ node: AtlasCodeGraphNode, target rawTarget: String) -> Bool {
        let target = rawTarget.trimmingCharacters(in: .whitespaces)
        guard !target.isEmpty else { return false }
        if node.hash == target || node.hash.hasPrefix(target) { return true }
        return node.refs.contains { ref in
            ref.replacingOccurrences(of: "HEAD -> ", with: "")
                .replacingOccurrences(of: "origin/", with: "")
                .trimmingCharacters(in: .whitespaces) == target
        }
    }

    var violatingHashes: Set<String> {
        guard let violations, let graph else { return [] }
        var hashes: Set<String> = []
        for violation in violations.violations {
            for node in graph.nodes where matches(node, target: violation.target) {
                hashes.insert(node.hash)
            }
        }
        return hashes
    }

    var healedHashes: Set<String> {
        guard let heal else { return [] }
        var hashes: Set<String> = []
        for receipt in heal.stepReceipts where receipt.status == "completed" {
            if let head = receipt.undoRef?["head"], !head.isEmpty {
                hashes.insert(head)
            }
        }
        return hashes
    }

    func state(for node: AtlasCodeGraphNode) -> AtlasCodeNodeState {
        AtlasCodeGraphState.state(
            for: node,
            defaultBranch: graph?.defaultBranch,
            violatingHashes: violatingHashes,
            healedHashes: healedHashes,
            spineHashes: spineHashes
        )
    }

    func ruleId(for node: AtlasCodeGraphNode) -> String? {
        violations?.violations.first { matches(node, target: $0.target) }?.ruleId
    }

    func ruleCanon(for node: AtlasCodeGraphNode) -> String? {
        violations?.violations.first { matches(node, target: $0.target) }?.ruleCanonRef
    }

    var hasViolations: Bool { !(violations?.violations.isEmpty ?? true) }

    var hasHealReceipt: Bool { !(heal?.stepReceipts.isEmpty ?? true) }

    var statusHeadline: String {
        let linha = violations?.trunk
        guard let violations else {
            return linha.map { "não consegui varrer a \($0)" } ?? "não consegui varrer a linha principal"
        }
        if violations.violations.count > 0 {
            let quantos = violations.violations.count
            return quantos == 1 ? "1 sem retorno" : "\(quantos) sem retorno"
        }
        let integra = linha.map { "\($0) íntegra" } ?? "linha principal íntegra"
        if hasHealReceipt { return "\(integra) · curada sem você" }
        return integra
    }

    var scanState: AtlasCodeScanState {
        guard let violations else { return .unknown }
        return violations.violations.isEmpty ? .clean : .violating
    }
}

// --- AtlasCodeModel.swift ---
@MainActor
@Observable
final class AtlasCodeModel {

    let client: AtlasClient
    private(set) var repo: String
    private(set) var phase: LoadPhase = .idle
    private(set) var graph: AtlasCodeGraphResponse?
    private(set) var violations: AtlasCodeViolationsResponse?
    private(set) var heal: AtlasCodeHealResponse?
    private(set) var week: AtlasCodeWeek?

    init(client: AtlasClient, repo: String = "atlas-server") {
        self.client = client
        self.repo = repo
    }

    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        phase = .idle
        graph = nil
        violations = nil
        heal = nil
        week = nil
        spineHashes = []
        undoError = nil
    }

    func load(before: String? = nil) async {
        let requested = repo
        phase = .loading
        do {
            let graph = try await client.getCodeGraph(repo: requested, before: before)
            guard repo == requested else { return }
            self.graph = graph
            spineHashes = AtlasCodeGraphState.spine(nodes: graph.nodes, head: graph.trunkHead)
            phase = .loaded

            async let violationsTask = client.getCodeViolations(repo: requested)
            async let healTask = client.getCodeHealTick(repo: requested)
            async let weekTask = client.getCodeWeek(repo: requested)
            let nextViolations = try? await violationsTask
            let nextHeal = try? await healTask
            let nextWeek = try? await weekTask
            guard repo == requested else { return }
            violations = nextViolations
            heal = nextHeal
            week = nextWeek
            AtlasNativeSnapshotWriter.shared.recordCodeWeek(week)
        } catch {
            guard repo == requested else { return }
            phase = .failed(String(describing: error))
        }
    }

    func undoLastHeal() async {
        guard let id = heal?.healId else { return }
        do {
            _ = try await client.undoCodeHeal(id: id, repo: repo)
            heal = try? await client.getCodeHealTick(repo: repo)
            graph = try? await client.getCodeGraph(repo: repo)
            violations = try? await client.getCodeViolations(repo: repo)
        } catch {
            undoError = "não consegui desfazer agora — a cura continua aqui, tente de novo."
        }
    }

    private(set) var undoError: String?

    var spineHashes: Set<String> = []
}
