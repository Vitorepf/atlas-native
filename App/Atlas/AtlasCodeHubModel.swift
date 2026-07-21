import Foundation
import AtlasCore

// GOD-RESTRUCTURE: Code hub+provenance models fused

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
