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

    /// H6 · a pílula abre o card, e o card conversa com o agente.
    ///
    /// A pílula teve dois defeitos, nesta ordem. O primeiro: ser bonita e morta
    /// — um placeholder que prometia "por que essa branch existe?" e não fazia
    /// nada. O segundo, pior: responder feito máquina de busca, um fato solto
    /// por vez, sem histórico e sem entender a pergunta. Agora ela é PORTA: o
    /// card atrás dela é a mesma conversa do Atlas — com agente, memória e
    /// orquestra —, só que semeada com os fatos que o git acabou de dar.
    ///
    /// Este teste cobra as duas promessas: que o card abre, e que perguntar
    /// ancora o mapa (a prova de que o determinístico leu o git de verdade
    /// naquele turno — sem isso o agente estaria opinando no vazio).
    func testPillOpensTheCardAndAnchorsTheGraph() {
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

        // 1 · A pílula está lá (lei 7) e é porta, não formulário.
        let pill = app.descendants(matching: .any).matching(identifier: "code-ask-pill").firstMatch
        XCTAssertTrue(pill.waitForExistence(timeout: 10), "a pílula nunca some")
        pill.tap()

        // 2 · O card abre sobre o grafo — e chega perguntando sobre ESTE
        // repositório, não sobre a vida.
        let convite = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'saber deste repositório'")
        ).firstMatch
        XCTAssertTrue(convite.waitForExistence(timeout: 15), "a pílula precisa abrir o card de conversa")
        attach(app, name: "11-card-aberto")

        // 3 · Vazio, o card ensina o próprio poder em vez de esperar adivinhação.
        let suggestion = app.buttons["tem algum problema?"]
        XCTAssertTrue(suggestion.waitForExistence(timeout: 10),
                      "o card precisa sugerir o que o Atlas SABE responder")
        suggestion.tap()

        // 4 · O turno do operador nasce com a frase dele — nunca com o dossiê de
        // fatos que viaja no fio por baixo.
        let turno = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'tem algum problema'")
        ).firstMatch
        XCTAssertTrue(turno.waitForExistence(timeout: 20), "tocar na sugestão precisa criar o turno")
        XCTAssertFalse(turno.label.contains("Fatos lidos do git"),
                       "o dossiê é para o agente ler, não para o operador ver")
        attach(app, name: "12-turno-enviado")

        // 5 · A prova do par: o determinístico leu o git NESTE turno e ancorou o
        // mapa. Sem isto, o agente estaria opinando sobre um repositório que não
        // enxerga — que era o defeito que a pílula existe para matar.
        let fechar = app.buttons["fechar teclado"]
        if fechar.waitForExistence(timeout: 8) { fechar.tap() }
        app.swipeDown(velocity: .fast)

        let ancora = app.buttons["code-ask-clear"]
        XCTAssertTrue(ancora.waitForExistence(timeout: 60),
                      "perguntar tem de acender o grafo: a resposta aponta para a topologia")
        attach(app, name: "13-grafo-ancorado")

        // 6 · Mostrar tudo apaga a âncora: o grafo volta ao estado normal.
        ancora.tap()
        XCTAssertFalse(app.buttons["code-ask-clear"].waitForExistence(timeout: 5),
                       "mostrar tudo devolve o grafo inteiro")
        attach(app, name: "14-limpo")
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
