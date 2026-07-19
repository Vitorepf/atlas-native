import XCTest

/// V1 · Cockpit postura: a home só mostra "VIVO AGORA" com sessão observada
/// neste processo; some quando a última sessão termina. Nunca guard-return
/// silencioso se a seção existir sem vida.
final class AtlasLiveNowTests: XCTestCase {

    @MainActor
    func testHomeShowsLiveNowOnlyWhileSessionIsAlive() {
        continueAfterFailure = false
        let app = XCUIApplication()
        let provider = ProcessInfo.processInfo.environment["ATLAS_DEVICE_PROOF_PROVIDER"] ?? "hermes_cli"
        app.launchEnvironment["ATLAS_DEVICE_PROOF_PROVIDER"] = provider
        app.launch()

        // Home ociosa: a seção NÃO pode existir sem sessão.
        XCTAssertTrue(app.buttons[A11yID.homeInputPill].waitForExistence(timeout: 45),
                      "home não abriu")
        attach(app, name: "01-home-idle")
        if app.descendants(matching: .any)[A11yID.liveNowSection].exists {
            XCTFail("VIVO AGORA não pode existir na home ociosa")
        }

        app.buttons[A11yID.homeInputPill].tap()
        // A pílula abre o picker; "Sem repositório" = conversa geral (o antigo "+").
        let semRepo = app.buttons[A11yID.workspacePickerNoRepo]
        XCTAssertTrue(semRepo.waitForExistence(timeout: 20), "picker não abriu com 'sem repositório'")
        semRepo.tap()
        let field = app.textFields[A11yID.conversationInput].exists
            ? app.textFields[A11yID.conversationInput]
            : app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 20), "composer não apareceu")
        field.tap()
        field.typeText("Execute obrigatoriamente sleep 8 && pwd com uma ferramenta shell read-only e responda apenas o caminho observado.")

        let send = app.buttons["enviar ao Atlas"]
        XCTAssertTrue(send.waitForExistence(timeout: 10), "envio real não ficou disponível")
        send.tap()

        // Volta à home enquanto o turno ainda vive.
        let back = app.buttons.matching(NSPredicate(format: "label CONTAINS 'chevron' OR identifier CONTAINS 'back'")).firstMatch
        if back.waitForExistence(timeout: 5) {
            back.tap()
        } else {
            // Fallback: o chevron.left da ConversationView não tem label —
            // toca o canto superior esquerdo da navegação.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.06, dy: 0.08)).tap()
        }

        let live = app.descendants(matching: .any)[A11yID.liveNowSection]
        XCTAssertTrue(live.waitForExistence(timeout: 120),
                      "home com turno vivo precisa mostrar VIVO AGORA")
        attach(app, name: "02-home-live")

        // Espera a sessão terminar — a seção some (lei 2).
        let deadline = Date().addingTimeInterval(600)
        while Date() < deadline && live.exists {
            RunLoop.current.run(until: Date().addingTimeInterval(2))
        }
        XCTAssertFalse(live.exists,
                       "VIVO AGORA deve sumir quando a última sessão termina")
        attach(app, name: "03-home-after-done")
    }

    @MainActor
    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
