import XCTest

/// Aprender-com-o-uso visível: a linha de ritmo existe em qualquer fase da
/// tela Autônomos e o toque abre a folha "O ritmo do seu dia". O teste prova
/// a casca sem depender do estado do aprendizado (linha aparece aprendendo OU
/// aprendida — as duas variantes carregam o mesmo identifier).
final class AtlasRhythmSheetTests: XCTestCase {

    func testRhythmLineOpensRhythmSheet() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()

        let autonomos = app.buttons[A11yID.homeAutonomosEntry]
        XCTAssertTrue(autonomos.waitForExistence(timeout: 45), "home precisa expor a área Autônomos")
        autonomos.tap()

        let line = app.buttons[A11yID.autonomosRhythmLine]
        XCTAssertTrue(line.waitForExistence(timeout: 45), "a linha de ritmo precisa existir na tela Autônomos")
        attach(app, name: "01-linha-ritmo")

        line.tap()
        let sheet = app.descendants(matching: .any)[A11yID.autonomosRhythmSheet]
        XCTAssertTrue(sheet.waitForExistence(timeout: 10), "toque na linha precisa abrir a folha do ritmo")
        XCTAssertTrue(app.staticTexts["O ritmo do seu dia"].waitForExistence(timeout: 5),
                      "a folha precisa dizer o que é: O ritmo do seu dia")
        attach(app, name: "02-folha-ritmo")

        app.swipeDown()
        XCTAssertTrue(line.waitForExistence(timeout: 10), "fechar a folha devolve a tela com a linha")
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
