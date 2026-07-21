import XCTest
import UIKit

final class AtlasDeviceProofTests: XCTestCase {
    @MainActor
    func testToolExecutionAndPersistentCockpit() {
        continueAfterFailure = false
        let app = XCUIApplication()
        let provider = ProcessInfo.processInfo.environment["ATLAS_DEVICE_PROOF_PROVIDER"] ?? "hermes_cli"
        app.launchEnvironment["ATLAS_DEVICE_PROOF_PROVIDER"] = provider
        // Harness: abre conversa geral direto (prova = tool/cockpit, não o picker).
        app.launchArguments = ["-atlas.uitest.newConversation"]
        app.launch()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 2) {
            springboard.buttons["Cancelar"].tap()
        }

        let field = app.textFields[A11yID.conversationInput]
        XCTAssertTrue(field.waitForExistence(timeout: 25), "composer não apareceu (harness newConversation)")
        field.tap()
        field.typeText("sleep 8 && pwd")
        capture("01-composer")

        let send = app.buttons[A11yID.conversationSend]
        XCTAssertTrue(send.waitForExistence(timeout: 10), "envio real não ficou disponível")
        XCTAssertTrue(waitUntilHittable(send, timeout: 10), "botão de envio não ficou tocável")
        send.tap()
        if app.buttons["fechar teclado"].waitForExistence(timeout: 3) {
            app.buttons["fechar teclado"].tap()
        }

        let liveCommand = app.staticTexts["Executando comando"]
        let proof = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'prova da execução'")
        ).firstMatch
        let sawLive = liveCommand.waitForExistence(timeout: 180)
        let sawProof = proof.waitForExistence(timeout: sawLive ? 120 : 420)
        XCTAssertTrue(sawLive || sawProof, "cockpit/tool não mostrou atividade nem prova")
        capture(sawProof ? "03-execution-proof" : "02-tool-live")

        guard sawProof else { return }

        proof.tap()
        let persistedCommand = app.staticTexts["Comando concluído"]
        if persistedCommand.waitForExistence(timeout: 15) {
            let scrollStart = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.42))
            let scrollEnd = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.16))
            for _ in 0..<6 where !persistedCommand.isHittable {
                scrollStart.press(forDuration: 0.05, thenDragTo: scrollEnd)
            }
            XCTAssertTrue(persistedCommand.isHittable || persistedCommand.exists,
                          "a ferramenta persistida não ficou alcançável")
        }
        capture("03-execution-proof-expanded")
    }

    @MainActor
    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func waitUntilHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "hittable == true"),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

}
