import AtlasCore
import Observation
import SwiftUI

/// A exceção do domínio Código, resolvida de dado real.
///
/// O hub NÃO repete a área (decisão do operador, 15/07): a única porta do
/// Atlas Código é o ícone da barra, à esquerda do masthead. Este model
/// alimenta o ponto vermelho desse ícone — estado por exceção: sem violação
/// real, nenhum sinal; e ele some sozinho quando o Atlas cura.
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
