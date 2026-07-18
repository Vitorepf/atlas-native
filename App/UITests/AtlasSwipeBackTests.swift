import XCTest

/// Prova do gesto de voltar pela borda nas telas de chrome próprio
/// (barra nativa oculta). O SwipeBackEnabler devolve o pop interativo;
/// este teste falha se o gesto morrer de novo.
final class AtlasSwipeBackTests: XCTestCase {

    func testEdgeSwipeReturnsHomeFromSearch() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let search = app.buttons[A11yID.topbarSearch]
        XCTAssertTrue(search.waitForExistence(timeout: 45), "home precisa expor a busca")
        search.tap()

        let searchScreen = app.descendants(matching: .any)[A11yID.searchScreen]
        XCTAssertTrue(searchScreen.waitForExistence(timeout: 10), "busca não abriu")

        // Swipe da borda esquerda — o gesto nativo de voltar.
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.1)

        let home = app.buttons[A11yID.homeInputPill]
        XCTAssertTrue(home.waitForExistence(timeout: 10), "gesto de voltar não devolveu a home")
    }
}
