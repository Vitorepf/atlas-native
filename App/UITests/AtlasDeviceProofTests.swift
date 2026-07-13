import XCTest

final class AtlasDeviceProofTests: XCTestCase {
    @MainActor
    func testToolExecutionAndPersistentCockpit() {
        continueAfterFailure = false
        let app = XCUIApplication()
        let provider = ProcessInfo.processInfo.environment["ATLAS_DEVICE_PROOF_PROVIDER"] ?? "hermes_cli"
        app.launchEnvironment["ATLAS_DEVICE_PROOF_PROVIDER"] = provider
        app.launch()
        let newConversation = app.buttons["Escreva ao Atlas"]
        XCTAssertTrue(newConversation.waitForExistence(timeout: 45), "home não abriu uma ação de conversa")
        newConversation.tap()

        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 20), "composer não apareceu")
        field.tap()
        field.typeText("Execute obrigatoriamente sleep 8 && pwd com uma ferramenta shell read-only e responda apenas o caminho observado.")
        capture("01-composer")

        let send = app.buttons["enviar ao Atlas"]
        XCTAssertTrue(send.waitForExistence(timeout: 10), "envio real não ficou disponível")
        XCTAssertTrue(waitUntilHittable(send, timeout: 10),
                      "botão de envio existe, mas não ficou tocável")
        send.tap()
        let sentTurn = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'Execute obrigatoriamente sleep 8'")
        ).firstMatch
        XCTAssertTrue(sentTurn.waitForExistence(timeout: 15),
                      "toque no envio não criou o turno do operador")
        let closeKeyboard = app.buttons["fechar teclado"]
        if closeKeyboard.waitForExistence(timeout: 5) { closeKeyboard.tap() }

        let liveCommand = app.staticTexts["Executando comando"]
        XCTAssertTrue(liveCommand.waitForExistence(timeout: 180),
                      "cockpit não mostrou a ferramenta shell enquanto ela executava")
        XCTAssertTrue(liveCommand.isHittable,
                      "a ferramenta shell ao vivo existe, mas está fora da região visível")
        capture("02-tool-live")

        let proof = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'prova da execução'")
        ).firstMatch
        XCTAssertTrue(proof.waitForExistence(timeout: 600), "prova persistente não apareceu após conclusão")

        let finalAnswer = app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH '/'")
        ).firstMatch
        XCTAssertTrue(finalAnswer.waitForExistence(timeout: 15),
                      "resposta final utilizável não apareceu separada da atividade")
        let rawReasoning = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'Reasoning'")
        )
        XCTAssertEqual(rawReasoning.count, 0,
                       "resposta final vazou o frame bruto de Reasoning")

        proof.tap()
        let persistedCommand = app.staticTexts["Comando concluído"]
        XCTAssertTrue(persistedCommand.waitForExistence(timeout: 15),
                      "a ferramenta executada não permaneceu registrada na prova")
        let scrollStart = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.42))
        let scrollEnd = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.16))
        for _ in 0..<6 where !persistedCommand.isHittable {
            scrollStart.press(forDuration: 0.05, thenDragTo: scrollEnd)
        }
        XCTAssertTrue(persistedCommand.isHittable,
                      "a ferramenta persistida existe, mas não ficou alcançável ao expandir a prova")
        capture("03-execution-proof-expanded")
    }

    @MainActor
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func waitUntilHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "hittable == true"),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

}
