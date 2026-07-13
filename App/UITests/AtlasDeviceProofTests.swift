import XCTest

final class AtlasDeviceProofTests: XCTestCase {
    @MainActor
    func testToolExecutionAndPersistentCockpit() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["ATLAS_DEVICE_PROOF_PROVIDER"] = "codex_cli"
        app.launch()
        let newConversation = app.buttons["Escreva ao Atlas"]
        XCTAssertTrue(newConversation.waitForExistence(timeout: 45), "home não abriu uma ação de conversa")
        newConversation.tap()

        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 20), "composer não apareceu")
        field.tap()
        field.typeText("No workspace atlas-server, execute obrigatoriamente sleep 8 && shasum -a 256 composer.json com uma ferramenta shell read-only e responda apenas o hash observado.")
        capture("01-composer")

        let send = app.buttons["enviar ao Atlas"]
        XCTAssertTrue(send.waitForExistence(timeout: 10), "envio real não ficou disponível")
        send.tap()
        let closeKeyboard = app.buttons["fechar teclado"]
        if closeKeyboard.waitForExistence(timeout: 5) { closeKeyboard.tap() }

        let liveActivity = app.staticTexts.matching(NSPredicate(
            format: "label IN %@",
            ["Entendendo o pedido", "Reunindo contexto", "Planejando a execução",
             "Iniciando o agente", "Executando comando", "Raciocinando sobre a tarefa",
             "Verificando o resultado", "Registrando evidências"]
        )).firstMatch
        XCTAssertTrue(liveActivity.waitForExistence(timeout: 180), "cockpit não mostrou atividade tipada ao vivo")
        capture("02-activity-live")

        let proof = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'prova da execução'")
        ).firstMatch
        XCTAssertTrue(proof.waitForExistence(timeout: 600), "prova persistente não apareceu após conclusão")
        proof.tap()
        let persistedCommand = app.staticTexts["Comando concluído"]
        XCTAssertTrue(persistedCommand.waitForExistence(timeout: 15),
                      "a ferramenta executada não permaneceu registrada na prova")
        let scrollStart = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.42))
        let scrollEnd = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.16))
        for _ in 0..<6 where !persistedCommand.isHittable {
            scrollStart.press(forDuration: 0.05, thenDragTo: scrollEnd)
        }
        capture("03-execution-proof-expanded")
    }

    @MainActor
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

}
