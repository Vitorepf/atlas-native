import XCTest

/// Tour de design — captura as superfícies principais com dados reais para a
/// crítica visual do polimento (casca). Não afirma conteúdo: só navega e
/// fotografa; a prova de comportamento vive nos testes dedicados.
final class AtlasDesignTourTests: XCTestCase {

    func testDesignTourCaptures() {
        continueAfterFailure = false
        // Diálogo de deep link pendente de sessão anterior cobre o app.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let home = app.buttons[A11yID.homeInputPill]
        XCTAssertTrue(home.waitForExistence(timeout: 45), "home não abriu")
        attach(app, name: "tour-01-home")

        let autonomos = app.buttons[A11yID.homeAutonomosEntry]
        XCTAssertTrue(autonomos.waitForExistence(timeout: 20), "home precisa expor Autônomos")
        autonomos.tap()

        let line = app.buttons[A11yID.autonomosRhythmLine]
        _ = line.waitForExistence(timeout: 45)
        attach(app, name: "tour-02-autonomos-topo")

        app.swipeUp()
        attach(app, name: "tour-03-autonomos-meio")
        app.swipeUp()
        attach(app, name: "tour-04-autonomos-frota")
        app.swipeUp()
        attach(app, name: "tour-05-autonomos-fim")

        if line.exists && line.isHittable {
            line.tap()
            if app.staticTexts["O ritmo do seu dia"].waitForExistence(timeout: 8) {
                attach(app, name: "tour-06-folha-ritmo")
            }
            app.swipeDown()
        }
    }

    func testDesignTourArena() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let arena = app.buttons[A11yID.arenaHomeEntry]
        XCTAssertTrue(arena.waitForExistence(timeout: 45), "home precisa expor a Arena")
        attach(app, name: "arena-00-home")
        arena.tap()
        sleep(3)
        attach(app, name: "arena-01-topo")
        app.swipeUp()
        attach(app, name: "arena-02-meio")
        app.swipeUp()
        attach(app, name: "arena-03-fim")
    }

    func testDesignTourConversa() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        // Conversa nova (composer vazio — estado inicial é design também).
        let pill = app.buttons[A11yID.homeInputPill]
        XCTAssertTrue(pill.waitForExistence(timeout: 45), "home não abriu")
        pill.tap()
        sleep(2)
        attach(app, name: "conversa-01-nova")
        // Overlay de tutorial do teclado do simulador rouba toques — relançar
        // é determinístico onde navegar de volta não é.
        app.terminate()
        app.launch()
        XCTAssertTrue(pill.waitForExistence(timeout: 30), "home não voltou após relaunch")

        // Conversa existente com conteúdo real: Todas as conversas (100+).
        let freeList = app.buttons[A11yID.homeWorkspaceAll]
        if freeList.waitForExistence(timeout: 10) {
            freeList.tap()
            sleep(2)
            attach(app, name: "conversa-02-lista")
            let firstThread = app.buttons.matching(
                NSPredicate(format: "identifier BEGINSWITH %@", A11yID.workspaceThreadPrefix)
            ).firstMatch
            let target = firstThread.exists ? firstThread : app.cells.firstMatch
            if target.waitForExistence(timeout: 10) {
                target.tap()
                sleep(3)
                attach(app, name: "conversa-03-thread")
                app.swipeDown()
                attach(app, name: "conversa-04-thread-historico")
            }
        }
    }

    func testDesignTourCodigo() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let code = app.buttons[A11yID.topbarCode]
        XCTAssertTrue(code.waitForExistence(timeout: 45), "home precisa expor o Atlas Código")
        code.tap()
        sleep(3)
        attach(app, name: "codigo-01-topo")
        app.swipeUp()
        attach(app, name: "codigo-02-meio")
        app.swipeUp()
        attach(app, name: "codigo-03-fim")
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
