import AtlasCore
import Observation

// Gramática de estado do grafo — peel de AtlasCodeModel (régua ~160).

extension AtlasCodeModel {
    // MARK: - Gramática de estado (cor = estado, nunca autor)

    /// Casa o alvo da violação (uma ref ou um hash) com os nós reais. Sem
    /// correspondência, nenhum nó acende — ausência nunca vira suspeita.
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

    /// Hashes que o Atlas curou sozinho — o recibo é a fonte, não a UI.
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

    /// A regra citada pelo nome — sinal primário, jamais erro genérico.
    func ruleId(for node: AtlasCodeGraphNode) -> String? {
        violations?.violations.first { matches(node, target: $0.target) }?.ruleId
    }

    /// O documento canônico que sustenta a acusação contra este nó.
    func ruleCanon(for node: AtlasCodeGraphNode) -> String? {
        violations?.violations.first { matches(node, target: $0.target) }?.ruleCanonRef
    }

    var hasViolations: Bool { !(violations?.violations.isEmpty ?? true) }

    var hasHealReceipt: Bool { !(heal?.stepReceipts.isEmpty ?? true) }

    /// Estado por exceção: quando o mundo está são, a tela diz isso e cala.
    /// Vocabulário canônico do operador: **sem retorno** (não “desvios”).
    var statusHeadline: String {
        let linha = violations?.trunk
        guard let violations else {
            return linha.map { "não consegui varrer a \($0)" } ?? "não consegui varrer a linha principal"
        }
        if violations.violations.count > 0 {
            let quantos = violations.violations.count
            // Unidade = contagem do scan (mesma da casca); §5 reconcilia obra/branch no Core.
            return quantos == 1 ? "1 sem retorno" : "\(quantos) sem retorno"
        }
        let integra = linha.map { "\($0) íntegra" } ?? "linha principal íntegra"
        if hasHealReceipt { return "\(integra) · curada sem você" }
        return integra
    }

    /// O estado geral que a cápsula pinta — TRÊS, não dois.
    var scanState: AtlasCodeScanState {
        guard let violations else { return .unknown }
        return violations.violations.isEmpty ? .clean : .violating
    }
}
