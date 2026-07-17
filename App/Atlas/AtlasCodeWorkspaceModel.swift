import AtlasCore
import Observation
import Foundation

/// M3 · Modelo do workspace do radar de Código.
///
/// Modelo mental correto: `Atlas/` e `blackink/` são PASTAS de produto que
/// contêm repositórios; pasta não é repositório quebrado. A tela mostra
/// **Recentes** (o trabalho vivo — atalho, não cópia) e **Pastas** (a verdade
/// completa). A exceção de cada repo aparece em português e é resolvida sob
/// demanda: varrer 12 repos de uma vez para pintar a lista seria caro; aqui
/// a exceção chega quando chega, e enquanto não chega a linha não fala.
@MainActor
@Observable
final class AtlasCodeWorkspaceModel {

    private let client: AtlasClient
    private(set) var phase: LoadPhase = .idle
    private(set) var workspace: AtlasCodeWorkspaceResponse?
    /// Exceções por repo (slug → issues). Chave ausente = ainda não varrido.
    private(set) var issuesBySlug: [String: [AtlasCodeIssue]] = [:]
    /// A trunk real de cada repo varrido — a frase da issue fala o nome da
    /// linha ("fora da production"), nunca "main" no chute.
    private(set) var trunkBySlug: [String: String] = [:]

    /// Repos que NÃO responderam. Falha é um fato e precisa ser guardada.
    ///
    /// Sem isto, o `continue` do scan fazia "falhou" e "ainda não varri"
    /// colapsarem no mesmo nil — e a cápsula agregava o vazio em alta: um repo
    /// respondendo `[]` entre doze mudos dava "nada pede você" com ✓ verde
    /// sobre uma frota 92% não varrida. O comentário do scan promete "jamais
    /// vira 0 problemas", e a promessa valia só para a LINHA do repo; a cápsula
    /// somava e virava exatamente o 0 que ele nega.
    ///
    /// Set separado, e não `[String: [Issue]?]`: o dicionário optional não
    /// compila aqui E mataria o retry — o guard do scan compara a chave, então
    /// repo mudo nunca mais seria varrido, nem no puxar-para-atualizar.
    private(set) var failedSlugs: Set<String> = []
    private(set) var expandedFolders: Set<String> = []

    init(client: AtlasClient) {
        self.client = client
    }

    func load() async {
        phase = .loading
        do {
            let response = try await client.getCodeWorkspace()
            workspace = response
            phase = .loaded
            // Os recentes são o que o operador olha primeiro: varre esses já.
            await scan(response.recents.map(\.slug))
        } catch {
            phase = .failed(String(describing: error))
        }
    }

    /// Varredura sob demanda: repo que não responde não ganha sinal — jamais
    /// vira "0 problemas".
    func scan(_ slugs: [String]) async {
        for slug in slugs where issuesBySlug[slug] == nil {
            guard let response = try? await client.getCodeViolations(repo: slug) else {
                // Falha é FATO: guardada, não engolida. Sem isto a cápsula soma
                // o silêncio como se fosse saúde.
                failedSlugs.insert(slug)
                continue
            }
            failedSlugs.remove(slug)
            issuesBySlug[slug] = Self.group(response.violations)
            if let trunk = response.trunk { trunkBySlug[slug] = trunk }
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

    /// A frase do workspace: o problema dominante entre o que já foi varrido.
    ///
    /// Quando nada pede o operador, a frase tem de dizer sobre QUANTOS repos
    /// ela está falando. "nada pede você" é um veredito sobre a frota, e emiti-lo
    /// a partir de uma amostra que a tela não conta é a primeira frase da
    /// ferramenta sendo um chute.
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

    /// O tom da cápsula do radar — TRÊS estados, como no grafo.
    ///
    /// Verde é afirmação ("varri a frota e nada pede você") e só pode sair
    /// quando a conta fecha. Repo mudo, ou varredura ainda não começada, é
    /// ausência: cinza. A tela dizia "lendo o workspace…" com um ✓ verde ao
    /// lado — dois estados contraditórios ao mesmo tempo, nenhum verdadeiro.
    var scanState: AtlasCodeScanState {
        if hasException { return .violating }
        if !failedSlugs.isEmpty || issuesBySlug.isEmpty { return .unknown }
        return .clean
    }

    /// Agrupa violações cruas por regra medindo a idade real do caso mais
    /// antigo — mesmo contrato do servidor.
    private static func group(_ violations: [AtlasCodeViolation], now: Date = Date()) -> [AtlasCodeIssue] {
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
    /// Swift 6: ISO8601DateFormatter não é Sendable. Instanciar por chamada é
    /// barato aqui (dezenas de datas, não milhares) e elimina o data race —
    /// correção real, não `nonisolated(unsafe)` varrendo o problema pra baixo
    /// do tapete.
    static func date(from text: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: text) { return date }
        return ISO8601DateFormatter().date(from: text)
    }
}
