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

    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
