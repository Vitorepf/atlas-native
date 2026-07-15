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
    private let repos: [String]
    /// Exceção resolvida a partir de dado real. `nil` = silêncio (nunca "0".)
    private(set) var exception: Exception?

    struct Exception: Equatable {
        let repo: String
        let ruleId: String
        let count: Int
    }

    init(client: AtlasClient, repos: [String] = ["atlas-server", "atlas-native"]) {
        self.client = client
        self.repos = repos
    }

    /// Varre as áreas e mantém apenas a primeira exceção real. Falha de rede
    /// não inventa exceção nem apaga a anterior de forma silenciosa: sem
    /// resposta, a linha simplesmente não fala.
    func refresh() async {
        for repo in repos {
            guard let response = try? await client.getCodeViolations(repo: repo) else { continue }
            if let first = response.violations.first {
                exception = Exception(repo: repo, ruleId: first.ruleId, count: response.violations.count)
                return
            }
        }
        exception = nil
    }
}
