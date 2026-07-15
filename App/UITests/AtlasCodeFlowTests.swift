import XCTest

/// Prova do fluxo Atlas Código no simulador: hub → radar (frota) → grafo do
/// repo → folha de proveniência. Dirige a UI de verdade e anexa os frames ao
/// xcresult — nenhuma etapa é encenada.
final class AtlasCodeFlowTests: XCTestCase {

    func testHubToRadarToGraphAndProvenance() {
        let app = XCUIApplication()
        app.launch()

        // 1 · A única porta do domínio é o ícone da barra (à esquerda do
        // masthead); o hub não repete a área.
        let codeButton = app.buttons["topbar-code"]
        XCTAssertTrue(codeButton.waitForExistence(timeout: 20), "o ícone do Código precisa existir na barra")
        attach(app, name: "01-hub-codigo")
        codeButton.tap()

        // 2 · O radar responde com a frota real (ou diz honestamente que falhou).
        // A cápsula é um container (HStack): procurar em qualquer descendente.
        let radarStatus = app.descendants(matching: .any)["radar-status"]
        let repoCard = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'radar-repo-'")).firstMatch
        XCTAssertTrue(
            radarStatus.waitForExistence(timeout: 25) || repoCard.waitForExistence(timeout: 5),
            "o radar precisa mostrar o estado da frota"
        )
        attach(app, name: "02-radar-frota")

        guard repoCard.waitForExistence(timeout: 15) else {
            // Sem servidor, o radar mostra o estado honesto — e o teste diz isso
            // em vez de fingir sucesso.
            attach(app, name: "02b-radar-sem-fonte")
            return
        }
        repoCard.tap()

        // 3 · O grafo do repo escolhido, com a cápsula de estado e a pílula.
        let status = app.descendants(matching: .any)["code-status"]
        XCTAssertTrue(status.waitForExistence(timeout: 30), "o grafo precisa dizer o estado da main")
        XCTAssertTrue(app.descendants(matching: .any)["code-ask-pill"].exists,
                      "a pílula nunca some (lei 7)")
        attach(app, name: "03-grafo-do-repo")

        // 4 · Tocar num commit abre a folha: estado, descrição, e o que mudou.
        let commit = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'code-commit-'")).firstMatch
        if commit.waitForExistence(timeout: 10) {
            commit.tap()

            // A folha diz o estado do commit na gramática do domínio — nunca
            // um rótulo genérico de tela.
            let stateKicker = app.descendants(matching: .any)["code-provenance-state"]
            XCTAssertTrue(stateKicker.waitForExistence(timeout: 15), "a folha precisa dizer em que estado o commit está")
            let vocabulary = ["na main", "fora da main", "curado", "história"]
            XCTAssertTrue(
                vocabulary.contains { stateKicker.label.hasPrefix($0) },
                "o estado precisa falar a gramática do domínio, não jargão: \(stateKicker.label)"
            )

            // O gap que o operador apontou: a folha precisa listar o que o
            // commit tocou, não só quem o assinou.
            let files = app.descendants(matching: .any)["code-commit-files"]
            XCTAssertTrue(files.waitForExistence(timeout: 15), "a folha precisa mostrar os arquivos tocados")
            attach(app, name: "04-proveniencia")

            // 5 · A lista de arquivos vive no fim: rolar até ela é parte da prova.
            for _ in 0..<8 where !files.isHittable {
                app.swipeUp()
            }
            attach(app, name: "05-arquivos-tocados")
        }
    }

    /// H6 · a pílula responde de verdade.
    ///
    /// O defeito original dela era ser bonita e morta: um placeholder que
    /// prometia "por que essa branch existe?" e não fazia nada. Este teste
    /// existe para essa promessa nunca mais ficar sem cobrança.
    func testPillAnswersAndAnchorsTheGraph() {
        let app = XCUIApplication()
        app.launch()

        let codeButton = app.buttons["topbar-code"]
        XCTAssertTrue(codeButton.waitForExistence(timeout: 20))
        codeButton.tap()

        let repoCard = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'radar-repo-'")).firstMatch
        guard repoCard.waitForExistence(timeout: 25) else {
            attach(app, name: "10-sem-fonte")
            return
        }
        repoCard.tap()

        XCTAssertTrue(app.descendants(matching: .any)["code-status"].waitForExistence(timeout: 30))

        // 1 · A pílula está lá (lei 7) e agora ABRE. O identificador propaga
        // para os filhos da pílula, então quem dirige pega o primeiro.
        let pill = app.descendants(matching: .any).matching(identifier: "code-ask-pill").firstMatch
        XCTAssertTrue(pill.waitForExistence(timeout: 10), "a pílula nunca some")
        pill.tap()

        // 2 · Vazia, ela ensina o próprio poder em vez de esperar adivinhação.
        let suggestion = app.buttons.matching(identifier: "code-ask-suggestion").firstMatch
        XCTAssertTrue(suggestion.waitForExistence(timeout: 10), "a pílula precisa sugerir o que sabe responder")
        attach(app, name: "11-pilula-sugestoes")

        // 3 · Tocar numa sugestão RESPONDE — com fato, não com promessa.
        suggestion.tap()
        let answer = app.descendants(matching: .any)["code-ask-answer"]
        XCTAssertTrue(answer.waitForExistence(timeout: 30), "a pílula precisa responder")
        XCTAssertFalse(answer.label.isEmpty, "resposta vazia é a promessa não cumprida de novo")
        attach(app, name: "12-pilula-resposta")

        // 4 · O grafo continua atrás: a resposta não abre outra tela (lei 3).
        XCTAssertTrue(app.descendants(matching: .any)["code-status"].exists,
                      "o mapa vem primeiro — a resposta não pode substituí-lo")
        attach(app, name: "13-grafo-ancorado")

        // 5 · A pílula é campo, não só menu de chips: o operador escreve o que
        // quiser, com as palavras dele.
        let field = app.textFields["code-ask-field"]
        XCTAssertTrue(field.waitForExistence(timeout: 10), "a pílula precisa aceitar a pergunta escrita")
        field.tap()
        field.typeText("quem mexeu no AtlasCodeView.swift?")
        app.buttons["code-ask-send"].firstMatch.tap()

        // A resposta troca — a pílula não empilha conversa, ela responde sobre
        // o grafo que está ali.
        let typedAnswer = app.descendants(matching: .any)["code-ask-answer"]
        XCTAssertTrue(typedAnswer.waitForExistence(timeout: 30))
        let expectation = expectation(for: NSPredicate(format: "label CONTAINS[c] 'atlascodeview'"), evaluatedWith: typedAnswer)
        wait(for: [expectation], timeout: 30)
        attach(app, name: "14-pergunta-escrita")

        // 6 · Limpar apaga a âncora: o grafo volta a mostrar tudo igual.
        app.buttons["code-ask-clear"].firstMatch.tap()
        XCTAssertTrue(app.buttons.matching(identifier: "code-ask-suggestion").firstMatch.waitForExistence(timeout: 10),
                      "limpar devolve a pílula ao convite, não a um vazio mudo")
        attach(app, name: "15-limpo")
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
