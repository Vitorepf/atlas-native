import Foundation
import AtlasCore

/// O bloco de fatos é o que impede o agente de inventar. Se ele mentir, mentir
/// COM autoridade — "lidos do git agora" — é pior que não existir. Por isso os
/// checks aqui cobrem as três formas de ele mentir: afirmar o que o
/// determinístico não afirmou, esconder recorte, e falar quando não sabe.
public func runAtlasCodeFactsChecks(_ check: (String, Bool) -> Void) {
    func response(
        answered: Bool = true,
        answer: String = "27 commits hoje: 70 arquivos, +7631 −3834.",
        commits: [String] = [],
        commitsTotal: Int? = nil,
        truncated: Bool = false,
        evidence: String = "[]",
        detail: String = ""
    ) -> AtlasCodeAskResponse? {
        let detail = detail.isEmpty ? "" : ",\"detail\":\"\(detail)\""
        let hashes = commits.map { "\"\($0)\"" }.joined(separator: ",")
        let json = """
        {
          "schema_version":"atlas.code.ask.v1",
          "repo":"atlas-server",
          "question":"o que mudou hoje?",
          "intent":"changes",
          "answered":\(answered),
          "answer":"\(answer)",
          "commits":[\(hashes)],
          "commits_total":\(commitsTotal ?? commits.count),
          "truncated":\(truncated),
          "evidence":\(evidence),
          "source":"git"\(detail)
        }
        """
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = atlasSnakeKeyDecoding
        return try? decoder.decode(AtlasCodeAskResponse.self, from: Data(json.utf8))
    }

    // O fato é a frase do determinístico, verbatim. Reescrever aqui seria
    // inventar uma segunda verdade sobre o mesmo git.
    let simples = response().flatMap(AtlasCodeFacts.block)
    check(
        "fatos citam a resposta determinística verbatim",
        simples?.contains("27 commits hoje: 70 arquivos, +7631 −3834.") == true
    )
    check(
        "fatos dizem ao agente que são do git e proíbem invenção",
        simples?.contains("atlas-server") == true && simples?.lowercased().contains("não invente") == true
    )

    // "não sei" do determinístico não vira dossiê vazio com ar de autoridade:
    // vira ausência, e o agente responde sem muleta.
    check(
        "determinístico sem resposta não produz bloco de fatos",
        response(answered: false, answer: "não sei responder isso.").flatMap(AtlasCodeFacts.block) == nil
    )
    check(
        "resposta vazia não vira bloco",
        response(answer: "   ").flatMap(AtlasCodeFacts.block) == nil
    )

    // O recorte é dito com número. "12" ao lado de "43 commits" na frase acima
    // leria como contradição; "12 de 43" lê como recorte.
    let muitos = (1...20).map { String(format: "%07xabc", $0) }
    let recorte = response(commits: muitos, commitsTotal: 43, truncated: true).flatMap(AtlasCodeFacts.block)
    check(
        "recorte de commits é dito com número, nunca cortado em silêncio",
        recorte?.contains("(12 de 43)") == true
    )
    check(
        "o teto de fio é 12 hashes, não o repositório inteiro",
        recorte.map { block in
            muitos.prefix(12).allSatisfy { block.contains($0) } && !block.contains(muitos[12])
        } == true
    )
    let poucos = response(commits: ["abc1234", "def5678"]).flatMap(AtlasCodeFacts.block)
    check(
        "sem recorte, o bloco não inventa um 'de N'",
        poucos?.contains("abc1234 def5678") == true && poucos?.contains("(2 de") == false
    )

    // A lei chega com alvo e canon: sem o documento, o agente só sabe dizer
    // "está errado porque sim".
    let comLei = response(
        evidence: """
        [{"kind":"rule","ref":"main_only","canon":"docs/engineering-knowledge-base/atlas-local-main-only-rule.md","target":"obra/refactor-x"}]
        """
    ).flatMap(AtlasCodeFacts.block)
    check(
        "a lei chega ao agente com alvo e documento canônico",
        comLei?.contains("main_only → obra/refactor-x") == true
            && comLei?.contains("atlas-local-main-only-rule.md") == true
    )
    check(
        "evidência que não é lei não vira lei",
        response(evidence: "[{\"kind\":\"commit\",\"ref\":\"abc1234\",\"canon\":null,\"target\":null}]")
            .flatMap(AtlasCodeFacts.block)?
            .contains("Leis do Atlas") == false
    )

    // Revisar sem ver o código é opinar. O diff vai no fio e NUNCA na tela.
    let comCodigo = response(
        answer: "3 commits hoje: 5 arquivos, +40 −2.",
        commits: ["abc1234"],
        detail: "Codigo dos commits:\\n--- commit abc1234 ---\\ndiff --git a/x b/x"
    ).flatMap(AtlasCodeFacts.block)
    check(
        "o codigo dos commits chega ao agente",
        comCodigo?.contains("diff --git a/x b/x") == true
    )
    check(
        "o codigo vem DEPOIS do fato, nao no lugar dele",
        comCodigo.map { block in
            guard let fato = block.range(of: "3 commits hoje"),
                  let codigo = block.range(of: "diff --git") else { return false }
            return fato.lowerBound < codigo.lowerBound
        } == true
    )
    check(
        "sem codigo, o bloco nao inventa uma secao vazia",
        response(commits: ["abc1234"]).flatMap(AtlasCodeFacts.block)?.contains("Codigo dos commits") == false
    )

    // A LEI DA ÂNCORA (o par do guarda em AtlasCodeAskModel.facts):
    // quem não leu o git não move o mapa. `answered` é o discriminador, não
    // "tem commit" — os dois silêncios são diferentes e só um apaga a âncora.
    check(
        "julgamento nao lido do git nao afirma nada (o mapa fica como esta)",
        response(answered: false, answer: "").flatMap(AtlasCodeFacts.block) == nil
    )
    check(
        "leitura que ENGAJOU e nao achou nada continua sendo fato",
        response(answer: "não há commit hoje.", commits: []).flatMap(AtlasCodeFacts.block) != nil
    )

    // A LEGENDA DO RECORTE: o servidor manda commits_total e truncated de
    // proposito para esta frase. Sem ela, 3/4 do mapa apagado le como "e so
    // isso" — mentira sobre o repositorio.
    // 12 é o teto REAL do servidor (MAX_ANCHORS): ele já corta antes de mandar,
    // então uma resposta com 20 âncoras não existe e testá-la seria testar
    // uma fantasia.
    let recortado = response(commits: (1...12).map { String(format: "%07xabc", $0) }, commitsTotal: 43, truncated: true)
    check(
        "a legenda diz o recorte com numero: '12 de 43'",
        recortado?.anchorNote == "12 de 43 acesos no grafo"
    )
    check(
        "sem recorte, a legenda nao inventa um 'de N'",
        response(commits: ["abc1234"]).map { $0.anchorNote == "1 commit aceso no grafo" } == true
    )
    check(
        "sem ancora nao ha legenda",
        response(commits: []).map { $0.anchorNote == nil } == true
    )
}
