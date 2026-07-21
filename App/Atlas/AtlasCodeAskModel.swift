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
    private(set) var repo: String
    private(set) var phase: Phase = .idle
    /// Legenda de âncora de swipe/proveniência — mesma voz da pílula e do emptyPrompt.
    /// Presentation-only; não é âncora de resposta git (`anchors` / `anchorNote`).
    private(set) var sheetFocusLegend: String?

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        phase = .idle
        sheetFocusLegend = nil
    }

    func setSheetFocusLegend(_ legend: String?) {
        let trimmed = legend?.trimmingCharacters(in: .whitespacesAndNewlines)
        sheetFocusLegend = (trimmed?.isEmpty == false) ? trimmed : nil
    }

    /// Os commits que a resposta atual cita. O grafo acende só estes.
    var anchors: Set<String> {
        if case .answered(let response) = phase { return response.anchorSet }
        return []
    }

    /// Verdadeiro quando há resposta apontando para commits: o grafo então
    /// apaga o resto, porque a resposta é o assunto.
    var isAnchoring: Bool { !anchors.isEmpty }

    /// A legenda do recorte: "12 de 43 acesos no grafo".
    ///
    /// Um mapa com 3/4 da história a 0.26 de opacidade e nenhuma frase dizendo
    /// o porquê lê como "é só isso" — que é mentira sobre o repositório. O
    /// servidor calcula `commits_total` e `truncated` exatamente para esta
    /// frase existir, e ela estava escrita e morta: `anchorNote` não tinha um
    /// único chamador no app inteiro. Contrato dos dois lados, faltando o Text.
    var anchorNote: String? {
        if case .answered(let response) = phase { return response.anchorNote }
        return nil
    }

    /// Limpar apaga a âncora de resposta: o grafo volta a mostrar tudo.
    /// Não mexe em `sheetFocusLegend` (swipe) — use `setSheetFocusLegend(nil)`.
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
    ///
    /// `answered` é o que decide se a topologia se move, e a distinção é fina:
    /// - `answered == false` → o git NÃO foi lido (julgamento, ou git mudo).
    ///   A leitura não tem opinião sobre o mapa, então o mapa fica como está.
    ///   Sem esta guarda, "explica melhor" — a coisa mais natural do mundo num
    ///   card de conversa — apagava em silêncio a resposta anterior, e a tese
    ///   da tela sobrevivia a exatamente um turno.
    /// - `answered == true` com zero commits → o git FOI lido e não há o que
    ///   acender ("nada mudou hoje"). Aí a âncora morre mesmo: a leitura nova é
    ///   a verdade nova, e segurar o mapa velho seria mentir com mapa.
    ///
    /// É a mesma guarda de `AtlasCodeFacts.block`: quem não leu não afirma.
    func facts(for question: String) async -> String? {
        guard let response = try? await client.askCode(repo: repo, question: question, mode: .facts),
              response.answered
        else { return nil }
        phase = .answered(response)
        return AtlasCodeFacts.block(from: response)
    }
}
