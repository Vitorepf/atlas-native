import XCTest

final class AtlasArenaFlowTests: XCTestCase {
    @MainActor
    func testHomeArenaIndexSuiteRunReceipt() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()

        // id vive no wrapper A11y (WorkspaceRow ignora filhos) — query por descendants.
        let arenaEntry = app.descendants(matching: .any)[A11yID.arenaHomeEntry]
        XCTAssertTrue(arenaEntry.waitForExistence(timeout: 60), "entrada Arena não apareceu na home")
        arenaEntry.tap()

        XCTAssertTrue(app.descendants(matching: .any)[A11yID.arenaScreen].waitForExistence(timeout: 20), "tela Arena não abriu")
        XCTAssertTrue(app.descendants(matching: .any)[A11yID.arenaIndexSection].waitForExistence(timeout: 60), "índice da Arena não carregou")
        capture(app, "01-arena-index")

        // Suítes agora vivem em disclosure (capacidades são o palco) — o
        // caminho do operador é: achar a linha, tocar, e ENTÃO ver a lista.
        let suitesToggle = app.buttons[A11yID.arenaSuitesToggle]
        XCTAssertTrue(scrollUntilVisible(suitesToggle, app: app, timeout: 30), "linha de suítes não apareceu")
        suitesToggle.tap()
        let suitesSection = app.descendants(matching: .any)[A11yID.arenaSuitesSection]
        XCTAssertTrue(scrollUntilVisible(suitesSection, app: app, timeout: 30), "seção SUITES não apareceu")
        let suite = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "arena-suite-")).firstMatch
        XCTAssertTrue(scrollUntilVisible(suite, app: app, timeout: 20), "nenhuma suite apareceu")
        suite.tap()
        XCTAssertTrue(app.descendants(matching: .any)[A11yID.arenaSuiteSheet].waitForExistence(timeout: 20), "sheet da suite não abriu")
        capture(app, "02-arena-suite")
        // AtlasCloseToolbarButton fala "fechar detalhes da suite" (AX label vence o título).
        app.buttons["fechar detalhes da suite"].tapIfExists()
        app.buttons["Done"].tapIfExists()
        app.buttons["Fechar"].tapIfExists()
        XCTAssertTrue(app.descendants(matching: .any)[A11yID.arenaSuiteSheet].waitForNonExistence(timeout: 10), "sheet da suite não fechou")

        let runButton = app.buttons[A11yID.arenaRunButton]
        XCTAssertTrue(scrollUntilVisible(runButton, app: app, timeout: 20), "botão Rodar medição ausente")
        // Borda inferior fica sob o home indicator após dismiss do sheet —
        // swipes curtos até o botão virar hittable antes do tap.
        let hittableDeadline = Date().addingTimeInterval(10)
        while !runButton.isHittable, Date() < hittableDeadline {
            app.swipeUp(velocity: .slow)
        }
        XCTAssertTrue(runButton.isHittable, "botão Rodar medição não ficou tocável")
        runButton.tap()
        XCTAssertTrue(app.descendants(matching: .any)[A11yID.arenaRunSheet].waitForExistence(timeout: 20), "run sheet não abriu")

        let actor = app.textFields[A11yID.arenaRunActor]
        XCTAssertTrue(actor.waitForExistence(timeout: 10), "campo ator ausente")
        actor.tap()
        actor.typeText("uitest")

        let submit = app.buttons[A11yID.arenaRunSubmit]
        XCTAssertTrue(submit.waitForExistence(timeout: 10), "submit ausente")
        XCTAssertFalse(submit.isEnabled, "sem motivo, a UI não pode enviar o POST que o servidor responderia 422")

        let reason = app.textFields[A11yID.arenaRunReason].exists
            ? app.textFields[A11yID.arenaRunReason]
            : app.textViews[A11yID.arenaRunReason]
        XCTAssertTrue(reason.waitForExistence(timeout: 10), "campo motivo ausente")
        reason.tap()
        reason.typeText("prova governada XCUITest")
        submit.tap()

        let receipt = app.descendants(matching: .any)[A11yID.arenaRunReceipt]
        XCTAssertTrue(receipt.waitForExistence(timeout: 60), "recibo enqueued não apareceu")
        XCTAssertTrue(app.staticTexts["na fila, ainda não iniciado"].waitForExistence(timeout: 10), "recibo não preservou fila")
        capture(app, "03-arena-receipt")
    }

    @MainActor
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func scrollUntilVisible(_ element: XCUIElement, app: XCUIApplication, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if element.exists && element.isHittable { return true }
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.86))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.18))
            start.press(forDuration: 0.01, thenDragTo: end)
            RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        }
        return element.exists
    }
}

private extension XCUIElement {
    @MainActor
    func tapIfExists() {
        if waitForExistence(timeout: 2) { tap() }
    }
}
