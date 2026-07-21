import XCTest
import UIKit

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

        // 2ª launch com harness de conversa — a prova é VIVO AGORA, não o picker.
        app.terminate()
        app.launchArguments = ["-atlas.uitest.newConversation"]
        app.launchEnvironment["ATLAS_DEVICE_PROOF_PROVIDER"] = provider
        app.launch()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 2) {
            springboard.buttons["Cancelar"].tap()
        }
        let field = app.descendants(matching: .any)[A11yID.conversationInput]
        XCTAssertTrue(field.waitForExistence(timeout: 30), "composer não apareceu")
        field.tap()
        field.typeText("sleep 8 && pwd")

        let send = app.descendants(matching: .any)[A11yID.conversationSend]
        let sendByLabel = app.buttons["enviar ao Atlas"]
        XCTAssertTrue(
            send.waitForExistence(timeout: 10) || sendByLabel.waitForExistence(timeout: 5),
            "envio real não ficou disponível"
        )
        (send.exists ? send : sendByLabel).tap()

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
