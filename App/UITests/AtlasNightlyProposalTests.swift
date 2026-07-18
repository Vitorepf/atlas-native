import XCTest

/// V2 · Proposta das 21h: o launch arg DEBUG injeta somente a proposta local.
/// O teste prova a casca (card + sheet prefilled + dismiss) sem acionar ciclo real.
final class AtlasNightlyProposalTests: XCTestCase {

    func testNightlyProposalCardOpensPrefilledSheetAndDismisses() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-atlas.nightly.demo", "1"]
        app.launch()

        let autonomos = app.buttons[A11yID.homeAutonomosEntry]
        XCTAssertTrue(autonomos.waitForExistence(timeout: 45), "home precisa expor a área Autônomos")
        autonomos.tap()

        let card = app.descendants(matching: .any)[A11yID.nightlyProposalCard]
        XCTAssertTrue(card.waitForExistence(timeout: 45), "Autônomos precisa mostrar a proposta pendente")
        attach(app, name: "01-card-proposta")

        app.buttons[A11yID.nightlyProposalAccept].tap()
        XCTAssertTrue(app.staticTexts["Preparar missão noturna"].waitForExistence(timeout: 10),
                      "aceite precisa abrir o sheet governado existente")
        let prefilled = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS 'missão noturna proposta' OR value CONTAINS 'missão noturna proposta'")
        ).firstMatch
        XCTAssertTrue(prefilled.waitForExistence(timeout: 10), "motivo precisa vir pré-preenchido")
        attach(app, name: "02-sheet-prefilled")

        // O botão visível "Cancelar" fala "cancelar ação governada" (AX label
        // vence o título nas queries) — query pela voz canônica.
        app.buttons["cancelar ação governada"].tap()
        XCTAssertTrue(card.waitForExistence(timeout: 10), "cancelar o sheet não deve descartar a proposta")
        app.buttons[A11yID.nightlyProposalDismiss].tap()
        XCTAssertFalse(card.waitForExistence(timeout: 5), "hoje não precisa silenciar o card")
        attach(app, name: "03-card-dismissed")
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
