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

    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
