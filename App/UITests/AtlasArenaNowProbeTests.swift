import XCTest

/// Sonda cirúrgica: a seção AGORA (feed live) está montada na Arena?
/// Existe porque o operador via a Arena muda enquanto o worker media
/// (2026-07-18) — o feed foi saneado no servidor e esta sonda é a prova
/// do lado da casca. Falha = liveRuns nil (fetch/decode) ou seção fora
/// da árvore.
final class AtlasArenaNowProbeTests: XCTestCase {
    @MainActor
    func testArenaNowSectionPresent() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let arena = app.buttons[A11yID.arenaHomeEntry]
        XCTAssertTrue(arena.waitForExistence(timeout: 45), "home precisa expor a Arena")
        arena.tap()

        let now = app.descendants(matching: .any)[A11yID.arenaNowSection]
        XCTAssertTrue(
            now.waitForExistence(timeout: 15),
            "AGORA ausente da Arena — liveRuns nil (fetch/decode do /arena/runs/live) ou seção desmontada"
        )
    }
}
