import Foundation
import Observation
import AtlasCore

/// H6 · a âncora do grafo.
///
/// Isto NÃO é o estado de uma conversa — a conversa é a `ConversationModel`, no
/// card. Aqui vive só a última leitura determinística do git: os commits que a
/// resposta citou, que o grafo acende atrás do vidro. Um grafo não tem duas
/// verdades ao mesmo tempo; perguntar de novo substitui, não empilha.
///
/// A divisão de trabalho: este model LÊ o git e ancora o mapa; o agente ENTENDE
/// e responde. Os fatos daqui viajam no fio como prefixo da pergunta.
@Observable
@MainActor
final class AtlasCodeAskModel {
    enum Phase: Equatable {
        case idle
        case answered(AtlasCodeAskResponse)
    }

    let client: AtlasClient
    let repo: String
    private(set) var phase: Phase = .idle

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

    /// Limpar apaga a âncora: o grafo volta a mostrar tudo.
    func clear() {
        phase = .idle
    }

    /// Os fatos de um turno da conversa, para o agente ler antes de responder.
    ///
    /// Efeito colateral deliberado: a mesma leitura ancora o grafo. Quando o
    /// card fecha, o mapa atrás já está aceso nos commits que sustentaram a
    /// resposta — perguntar move a topologia, que é o ponto da tela.
    ///
    /// `nil` quando o determinístico não sabe (julgamento não é filtro de git) e
    /// quando a rede cai: o agente responde sem muleta, e falha de rede nunca
    /// vira fato inventado com ar de autoridade.
    func facts(for question: String) async -> String? {
        guard let response = try? await client.askCode(repo: repo, question: question, mode: .facts) else { return nil }
        phase = .answered(response)
        return AtlasCodeFacts.block(from: response)
    }
}
