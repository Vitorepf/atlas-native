import Foundation
import Observation
import AtlasCore

/// H6 · o estado da pílula.
///
/// Deliberadamente NÃO guarda histórico de conversa: a pílula não é um chat.
/// Existe a última pergunta e a última resposta, porque a resposta vive
/// ancorada no grafo que está atrás dela — e um grafo não tem duas verdades
/// ao mesmo tempo. Perguntar de novo substitui; não empilha.
@Observable
@MainActor
final class AtlasCodeAskModel {
    enum Phase: Equatable {
        case idle
        case asking(String)
        case answered(AtlasCodeAskResponse)
        case failed(String)
    }

    let client: AtlasClient
    let repo: String
    private(set) var phase: Phase = .idle
    /// Aberta = a pílula virou campo. Fechada = ela volta a ser convite.
    var isOpen = false
    var draft = ""

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    /// Os commits que a resposta atual cita. O grafo acende só estes.
    var anchors: Set<String> {
        if case .answered(let response) = phase { return response.anchorSet }
        return []
    }

    /// Verdadeiro quando há resposta apontando para commits: o grafo então
    /// apaga o resto, porque a resposta é o assunto.
    var isAnchoring: Bool { !anchors.isEmpty }

    func ask(_ question: String) async {
        let asked = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !asked.isEmpty else { return }

        phase = .asking(asked)
        draft = ""
        do {
            let response = try await client.askCode(repo: repo, question: asked)
            phase = .answered(response)
        } catch {
            // Erro de rede não vira resposta plausível: vira erro dito.
            phase = .failed(String(describing: error))
        }
    }

    /// Limpar apaga a âncora: o grafo volta a mostrar tudo.
    func clear() {
        phase = .idle
        draft = ""
    }
}
