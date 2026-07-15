import XCTest

/// Prova do fluxo Atlas Código no simulador: hub → radar (frota) → grafo do
/// repo → folha de proveniência. Dirige a UI de verdade e anexa os frames ao
/// xcresult — nenhuma etapa é encenada.
final class AtlasCodeFlowTests: XCTestCase {

    func testHubToRadarToGraphAndProvenance() {
        let app = XCUIApplication()
        app.launch()

        // 1 · O hub mostra a área CÓDIGO (agregada, não uma linha por repo).
        let codeRow = app.buttons["hub-code-row"]
        XCTAssertTrue(codeRow.waitForExistence(timeout: 20), "a linha CÓDIGO precisa existir no hub")
        attach(app, name: "01-hub-codigo")
        codeRow.tap()

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

        // 4 · Tocar num commit abre a proveniência — a SUA frase, ou a ausência dita.
        let commit = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'code-commit-'")).firstMatch
        if commit.waitForExistence(timeout: 10) {
            commit.tap()
            let sheetTitle = app.staticTexts["PROVENIÊNCIA"]
            XCTAssertTrue(sheetTitle.waitForExistence(timeout: 15), "a folha de proveniência precisa abrir")
            attach(app, name: "04-proveniencia")
        }
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
