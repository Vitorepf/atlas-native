import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: CodeModels fused

// MARK: - AtlasCodeHubModel

// MARK: - Hub

@MainActor
@Observable
final class AtlasCodeHubModel {
    private let client: AtlasClient
    /// Exceção resolvida a partir de dado real. `nil` = silêncio (nunca "0".)
    private(set) var exception: Exception?

    struct Exception: Equatable {
        let repo: String
        let ruleId: String
        let count: Int
    }

    init(client: AtlasClient) {
        self.client = client
    }

    /// Varre as áreas e mantém apenas a primeira exceção real. Falha de rede
    /// não inventa exceção nem apaga a anterior de forma silenciosa: sem
    /// resposta, a linha simplesmente não fala.
    /// Varre os repositórios recentes — o trabalho vivo. Sem resposta, o
    /// ponto não acende: ausência nunca vira exceção.
    func refresh() async {
        guard let workspace = try? await client.getCodeWorkspace() else { return }

        // Apagar o ponto é uma AFIRMAÇÃO ("varri e está são") e só pode sair
        // de uma varredura que respondeu. Antes, se TODAS as leituras
        // falhassem, o laço terminava e `exception = nil` apagava o ponto
        // sobre uma frota que ninguém varreu — a mesma alta em verde da
        // cápsula, em miniatura. Falha mantém o estado anterior: o ponto que
        // estava aceso continua aceso até uma leitura real dizer o contrário.
        var scanned = false
        for repo in workspace.recents {
            guard let response = try? await client.getCodeViolations(repo: repo.slug) else { continue }
            scanned = true
            if let first = response.violations.first {
                exception = Exception(repo: repo.name, ruleId: first.ruleId, count: response.violations.count)
                return
            }
        }
        if scanned { exception = nil }
    }
}

// MARK: - Provenance

@MainActor
@Observable
final class AtlasCodeProvenanceModel {
    enum Phase: Equatable {
        case idle, loading, loaded(AtlasCodeProvenance), failed(String)
    }

    let client: AtlasClient
    private(set) var repo: String
    private(set) var phase: Phase = .idle
    /// O commit que a folha ABERTA pediu. Resposta de pedido velho não grava.
    private var wanted: String?

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        phase = .idle
        wanted = nil
    }

    func load(hash: String) async {
        // A corrida real: o operador toca no commit A, fecha, toca no B — e a
        // resposta de A chega DEPOIS da de B. Sem correlacionar, a folha do B
        // mostrava a proveniência do A: autor, arquivos e "sua frase" do commit
        // errado, na tela em que o operador decide se apaga trabalho. Só a
        // resposta do pedido mais recente pode escrever o estado.
        wanted = hash
        phase = .loading
        do {
            let provenance = try await client.getCodeProvenance(hash: hash, repo: repo)
            guard wanted == hash else { return }
            phase = .loaded(provenance)
        } catch {
            guard wanted == hash else { return }
            phase = .failed(String(describing: error))
        }
    }
}
// MARK: - AtlasCodeWorkspaceModel

extension AtlasCodeWorkspaceModel {
    func scan(_ slugs: [String]) async {
        for slug in slugs where issuesBySlug[slug] == nil {
            guard let response = try? await client.getCodeViolations(repo: slug) else {
                failedSlugs.insert(slug)
                continue
            }
            failedSlugs.remove(slug)
            issuesBySlug[slug] = Self.group(response.violations)
            if let trunk = response.trunk { trunkBySlug[slug] = trunk }
        }
    }

    var headline: String {
        let all = issuesBySlug.values.flatMap { $0 }
        guard !all.isEmpty else {
            if !failedSlugs.isEmpty {
                let mudos = failedSlugs.count
                return mudos == 1 ? "1 repositório não respondeu" : "\(mudos) repositórios não responderam"
            }
            return issuesBySlug.isEmpty ? "lendo o workspace…" : "nada pede você"
        }
        var byRule: [String: AtlasCodeIssue] = [:]
        for issue in all {
            if let existing = byRule[issue.ruleId] {
                byRule[issue.ruleId] = AtlasCodeIssue(
                    ruleId: issue.ruleId,
                    count: existing.count + issue.count,
                    severity: existing.isSevere || issue.isSevere ? "high" : issue.severity,
                    oldestDays: [existing.oldestDays, issue.oldestDays].compactMap { $0 }.max()
                )
            } else {
                byRule[issue.ruleId] = issue
            }
        }
        let worst = byRule.values.sorted { ($0.isSevere ? 0 : 1, -$0.count) < ($1.isSevere ? 0 : 1, -$1.count) }
        return worst.first?.headline ?? "nada pede você"
    }

    var hasException: Bool { issuesBySlug.values.contains { !$0.isEmpty } }

    var scanState: AtlasCodeScanState {
        if hasException { return .violating }
        if !failedSlugs.isEmpty || issuesBySlug.isEmpty { return .unknown }
        return .clean
    }

    static func group(_ violations: [AtlasCodeViolation], now: Date = Date()) -> [AtlasCodeIssue] {
        var byRule: [String: (count: Int, severe: Bool, oldest: Int?)] = [:]
        for violation in violations {
            var entry = byRule[violation.ruleId] ?? (0, false, nil)
            entry.count += 1
            entry.severe = entry.severe || violation.severity == "high"
            if let since = violation.since, let date = AtlasCodeISO.date(from: since) {
                let days = max(0, Int(now.timeIntervalSince(date) / 86_400))
                entry.oldest = max(entry.oldest ?? 0, days)
            }
            byRule[violation.ruleId] = entry
        }
        return byRule
            .map { AtlasCodeIssue(ruleId: $0.key, count: $0.value.count, severity: $0.value.severe ? "high" : "medium", oldestDays: $0.value.oldest) }
            .sorted { ($0.isSevere ? 0 : 1, -$0.count) < ($1.isSevere ? 0 : 1, -$1.count) }
    }
}

enum AtlasCodeISO {
    static func date(from text: String) -> Date? {
        AtlasTime.date(text)
    }
}

@MainActor
@Observable
final class AtlasCodeWorkspaceModel {

    let client: AtlasClient
    private(set) var phase: LoadPhase = .idle
    private(set) var workspace: AtlasCodeWorkspaceResponse?
    var issuesBySlug: [String: [AtlasCodeIssue]] = [:]
    var trunkBySlug: [String: String] = [:]
    var failedSlugs: Set<String> = []
    var expandedFolders: Set<String> = []

    init(client: AtlasClient) {
        self.client = client
    }

    func seedFromCache() {
        guard let cached = AtlasCodeWorkspaceCache.peek() else { return }
        workspace = cached
        phase = .loaded
    }

    func load() async {
        phase = .loading
        do {
            let response = try await client.getCodeWorkspace()
            AtlasCodeWorkspaceCache.store(response)
            workspace = response
            phase = .loaded
            await scan(response.recents.map(\.slug))
        } catch {
            phase = .failed(String(describing: error))
        }
    }

    func loadStructure() async {
        if let cached = AtlasCodeWorkspaceCache.peek() {
            workspace = cached
            phase = .loaded
            return
        }
        phase = .loading
        do {
            let response = try await client.getCodeWorkspace()
            AtlasCodeWorkspaceCache.store(response)
            workspace = response
            phase = .loaded
        } catch {
            phase = .failed(String(describing: error))
        }
    }

    func toggle(_ folder: AtlasCodeFolder) async {
        if expandedFolders.contains(folder.slug) {
            expandedFolders.remove(folder.slug)
        } else {
            expandedFolders.insert(folder.slug)
            await scan(folder.repos.map(\.slug))
        }
    }

    func issues(for slug: String) -> [AtlasCodeIssue]? { issuesBySlug[slug] }

    func trunk(for slug: String) -> String? { trunkBySlug[slug] }
}
// MARK: - AtlasCodeModel

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
            // WAVE-048: clear presentation undo failure only after success.
            undoError = nil
        } catch {
            undoError = "não consegui desfazer agora — a cura continua aqui, tente de novo."
        }
    }

    /// WAVE-048: operator-visible undo failure (was dark).
    private(set) var undoError: String?

    var spineHashes: Set<String> = []
}
