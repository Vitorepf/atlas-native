import AtlasCore
import Observation

@MainActor
@Observable
final class AtlasCodeModel {
    enum Phase: Equatable {
        case idle, loading, loaded, failed(String)
    }

    let client: AtlasClient
    let repo: String
    private(set) var phase: Phase = .idle
    private(set) var graph: AtlasCodeGraphResponse?
    private(set) var violations: AtlasCodeViolationsResponse?
    private(set) var heal: AtlasCodeHealResponse?
    private(set) var week: AtlasCodeWeek?

    init(client: AtlasClient, repo: String = "atlas-server") {
        self.client = client
        self.repo = repo
    }

    func load(before: String? = nil) async {
        phase = .loading
        do {
            let graph = try await client.getCodeGraph(repo: repo, before: before)
            self.graph = graph
            // A espinha vem da travessia dos pais a partir do head, não das
            // refs: o git decora só a ponta, e sem isto 197 dos 200 commits da
            // main apareciam como história cinza.
            spineHashes = AtlasCodeGraphState.spine(nodes: graph.nodes, head: graph.head)
            // A stale or unavailable scan must not hide a valid topology.
            violations = try? await client.getCodeViolations(repo: repo)
            heal = try? await client.getCodeHealTick(repo: repo)
            week = try? await client.getCodeWeek(repo: repo)
            phase = .loaded
        } catch {
            phase = .failed(String(describing: error))
        }
    }

    func undoLastHeal() async {
        guard let id = heal?.healId else { return }
        do {
            _ = try await client.undoCodeHeal(id: id, repo: repo)
            heal = try? await client.getCodeHealTick(repo: repo)
            // O veto muda o mundo: o mapa tem de contar a verdade nova.
            graph = try? await client.getCodeGraph(repo: repo)
            violations = try? await client.getCodeViolations(repo: repo)
        } catch {
            heal = nil
        }
    }

    // MARK: - Gramática de estado (cor = estado, nunca autor)

    /// Casa o alvo da violação (uma ref ou um hash) com os nós reais. Sem
    /// correspondência, nenhum nó acende — ausência nunca vira suspeita.
    private func matches(_ node: AtlasCodeGraphNode, target rawTarget: String) -> Bool {
        let target = rawTarget.trimmingCharacters(in: .whitespaces)
        guard !target.isEmpty else { return false }
        if node.hash == target || node.hash.hasPrefix(target) { return true }
        return node.refs.contains { ref in
            ref.replacingOccurrences(of: "HEAD -> ", with: "")
                .replacingOccurrences(of: "origin/", with: "")
                .trimmingCharacters(in: .whitespaces) == target
        }
    }

    private var violatingHashes: Set<String> {
        guard let violations, let graph else { return [] }
        var hashes: Set<String> = []
        for violation in violations.violations {
            for node in graph.nodes where matches(node, target: violation.target) {
                hashes.insert(node.hash)
            }
        }
        return hashes
    }

    /// Hashes que o Atlas curou sozinho — o recibo é a fonte, não a UI.
    private var healedHashes: Set<String> {
        guard let heal else { return [] }
        var hashes: Set<String> = []
        for receipt in heal.stepReceipts where receipt.status == "completed" {
            if let head = receipt.undoRef?["head"], !head.isEmpty {
                hashes.insert(head)
            }
        }
        return hashes
    }

    /// A espinha inteira, calculada UMA vez por grafo — não uma travessia por
    /// nó, que seria O(n²) numa lista que rola.
    private var spineHashes: Set<String> = []

    func state(for node: AtlasCodeGraphNode) -> AtlasCodeNodeState {
        AtlasCodeGraphState.state(
            for: node,
            defaultBranch: graph?.defaultBranch,
            violatingHashes: violatingHashes,
            healedHashes: healedHashes,
            spineHashes: spineHashes
        )
    }

    /// A regra citada pelo nome — sinal primário, jamais erro genérico.
    func ruleId(for node: AtlasCodeGraphNode) -> String? {
        violations?.violations.first { matches(node, target: $0.target) }?.ruleId
    }

    var hasViolations: Bool { !(violations?.violations.isEmpty ?? true) }

    var hasHealReceipt: Bool { !(heal?.stepReceipts.isEmpty ?? true) }

    /// Estado por exceção: quando o mundo está são, a tela diz isso e cala.
    ///
    /// `nil` NÃO é `[]`. A varredura falhando (rede, 500, timeout) devolvia nil
    /// pelo `try?` do load, e nil caía direto no "main íntegra" — a tela dava
    /// alta ao repositório sem ter olhado para ele. É a mesma classe de mentira
    /// do git que devolvia "nada mudou hoje" ao estourar o tempo: silêncio de
    /// falha vestido de boa notícia, e a boa notícia é o que o operador quer
    /// ouvir, então ele acredita e vai dormir.
    var statusHeadline: String {
        guard let violations else { return "não consegui varrer a main" }
        if violations.violations.count > 0 {
            return violations.violations.count == 1 ? "1 desvio da main" : "\(violations.violations.count) desvios da main"
        }
        if hasHealReceipt { return "main íntegra · curada sem você" }
        return "main íntegra"
    }

    /// A varredura respondeu? Sem isto a tela não tem como distinguir "está são"
    /// de "não olhei", e cor é ESTADO: dourado de alta sem exame é a cor
    /// mentindo, que é o pior lugar para uma mentira nesta tela.
    var scanAnswered: Bool { violations != nil }
}
