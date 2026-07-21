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
        let accept = app.descendants(matching: .any)[A11yID.nightlyProposalAccept]
        XCTAssertTrue(
            card.waitForExistence(timeout: 20) || accept.waitForExistence(timeout: 25),
            "Autônomos precisa mostrar a proposta pendente"
        )
        attach(app, name: "01-card-proposta")

        let acceptButton = accept.exists ? accept : app.buttons[A11yID.nightlyProposalAccept]
        XCTAssertTrue(acceptButton.waitForExistence(timeout: 10), "botão Preparar precisa existir")
        acceptButton.tap()
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
        // Após cancelar, a proposta continua (accept CTA ainda no ecrã).
        let acceptAgain = app.descendants(matching: .any)[A11yID.nightlyProposalAccept]
        XCTAssertTrue(
            card.waitForExistence(timeout: 8) || acceptAgain.waitForExistence(timeout: 8),
            "cancelar o sheet não deve descartar a proposta"
        )
        let dismiss = app.descendants(matching: .any)[A11yID.nightlyProposalDismiss]
        XCTAssertTrue(dismiss.waitForExistence(timeout: 8), "hoje não precisa existir")
        dismiss.tap()
        XCTAssertFalse(
            acceptAgain.waitForExistence(timeout: 5) || card.waitForExistence(timeout: 2),
            "hoje não precisa silenciar o card"
        )
        attach(app, name: "03-card-dismissed")
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
