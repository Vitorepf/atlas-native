import AtlasCore
import Observation

@MainActor
@Observable
final class AtlasCodeModel {

    let client: AtlasClient
    let repo: String
    private(set) var phase: LoadPhase = .idle
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
            // A espinha nasce da ponta da TRUNK e desce pelos pais.
            //
            // Duas coisas que pareciam uma: o git decora só a ponta (por isso a
            // travessia), e `head` é onde o OPERADOR está, não a trunk (por
            // isso `trunkHead`). Traçar do `head` numa obra pintaria a obra
            // inteira de dourado — a exceção vestida de norma. Sem trunk, sem
            // espinha: pinta menos, nunca pinta errado.
            spineHashes = AtlasCodeGraphState.spine(nodes: graph.nodes, head: graph.trunkHead)
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

    /// O documento canônico que sustenta a acusação contra este nó.
    ///
    /// O contrato C24 promete `rule_canon_ref` desde o começo e o servidor o
    /// manda; o app não tinha o campo e a lei morria no fio. Acusar sem citar a
    /// lei é o pior silêncio de uma ferramenta de governança — "está errado
    /// porque sim" é autoridade sem prova, e é o que faz o operador parar de
    /// confiar na cor.
    func ruleCanon(for node: AtlasCodeGraphNode) -> String? {
        violations?.violations.first { matches(node, target: $0.target) }?.ruleCanonRef
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
        // A linha pelo nome REAL dela. "main" estava escrito na mão, e metade da
        // frota não tem main — a trunk do nivor-back-end é `production`. Dizer
        // "desvio da main" sobre um repositório sem main é a tela afirmando com
        // segurança uma coisa que não existe, e o operador que for conferir no
        // git não acha o que ela citou.
        //
        // Sem trunk (ambígua, ou servidor antigo), a frase fala de desvio sem
        // nomear a linha: é o que se sabe, e nomear no chute seria pior.
        let linha = violations?.trunk
        guard let violations else {
            return linha.map { "não consegui varrer a \($0)" } ?? "não consegui varrer a linha principal"
        }
        if violations.violations.count > 0 {
            let quantos = violations.violations.count
            let alvo = linha.map { " da \($0)" } ?? ""
            return quantos == 1 ? "1 desvio\(alvo)" : "\(quantos) desvios\(alvo)"
        }
        let integra = linha.map { "\($0) íntegra" } ?? "linha principal íntegra"
        if hasHealReceipt { return "\(integra) · curada sem você" }
        return integra
    }

    /// O estado geral que a cápsula pinta — TRÊS, não dois.
    ///
    /// O código conhecia só `hasViolations`: verdadeiro = alerta, falso = alta
    /// em verde com ✓. E `falso` cobria duas coisas opostas: "varri e está são"
    /// e "não consegui varrer". A varredura caindo dava alta ao repositório com
    /// um tique verde — cor é ESTADO, e o estado ali era "não olhei".
    ///
    /// Eu mesmo escrevi `scanAnswered` ao consertar a manchete e esqueci de
    /// ligar na cor: a frase dizia "não consegui varrer a main" e a cápsula
    /// continuava verde ao redor dela. Meio conserto é pior que nenhum — a
    /// frase honesta com a cor mentindo ensina o operador a ler a cor, que é
    /// mais rápida, e ignorar a frase.
    var scanState: AtlasCodeScanState {
        guard let violations else { return .unknown }
        return violations.violations.isEmpty ? .clean : .violating
    }
}
