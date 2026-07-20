import XCTest

final class AtlasArenaFlowTests: XCTestCase {
    @MainActor
    func testPremiumArenaNavigationAndGovernedControls() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-atlas.arena.scenario", "running"]
        app.launch()

        XCTAssertTrue(element(A11yID.arenaPremiumState("running"), in: app).waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["casos confirmados"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons[A11yID.arenaPremiumAskPill].exists)
        capture(app, "arena-premium-01-running")

        app.buttons[A11yID.arenaPremiumExecutionAction].tap()
        XCTAssertTrue(element(A11yID.arenaPremiumExecution, in: app).waitForExistence(timeout: 10))
        XCTAssertTrue(element(A11yID.arenaPremiumExecutionPipeline, in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Pipeline"].exists || app.staticTexts["PIPELINE"].exists)
        XCTAssertTrue(app.staticTexts["Corridas"].exists || app.staticTexts["CORRIDAS"].exists)
        let liveRun = app.buttons[A11yID.arenaPremiumExecutionRun("run_live")]
        if liveRun.waitForExistence(timeout: 5) {
            liveRun.tap()
            XCTAssertTrue(element(A11yID.arenaPremiumRunDetail, in: app).waitForExistence(timeout: 5))
            capture(app, "arena-premium-03b-run-detail")
            app.navigationBars.buttons.firstMatch.tap()
        }
        capture(app, "arena-premium-03-execution")
        app.navigationBars.buttons.firstMatch.tap()

        // Fila/Plano/Cobertura saíram da Agora — o mapa mora em Execução.
        // Alertas só aparece com exceção real no cenário.
        if app.buttons[A11yID.arenaPremiumAlertsAction].exists {
            app.buttons[A11yID.arenaPremiumAlertsAction].tap()
            XCTAssertTrue(element(A11yID.arenaPremiumAlerts, in: app).waitForExistence(timeout: 10))
            capture(app, "arena-premium-06-alerts")
            app.navigationBars.buttons.firstMatch.tap()
        }

        app.buttons[A11yID.arenaPremiumTab("frota")].tap()
        XCTAssertTrue(element(A11yID.arenaPremiumFleet, in: app).waitForExistence(timeout: 10))
        capture(app, "arena-premium-02b-fleet")

        app.buttons[A11yID.arenaPremiumTab("motor")].tap()
        XCTAssertTrue(element(A11yID.arenaPremiumResults, in: app).waitForExistence(timeout: 10))
        capture(app, "arena-premium-02-results")

        let suite = app.buttons[A11yID.arenaPremiumResultSuite("live_code_bench")]
        XCTAssertTrue(scrollUntilVisible(suite, app: app), "resultado da suíte precisa estar acessível")
        suite.tap()
        XCTAssertTrue(element(A11yID.arenaSuiteSheet, in: app).waitForExistence(timeout: 10))
        capture(app, "arena-premium-03-suite")
        app.buttons["fechar detalhes da suite"].tapIfExists()
        app.buttons["Done"].tapIfExists()
        app.buttons["Fechar"].tapIfExists()

        app.buttons[A11yID.arenaPremiumTab("capacidades")].tap()
        XCTAssertTrue(element(A11yID.arenaPremiumCapabilities, in: app).waitForExistence(timeout: 10))
        capture(app, "arena-premium-09-capabilities")
        let capability = app.buttons[A11yID.arenaCapabilityRow("code_editing")]
        XCTAssertTrue(scrollUntilVisible(capability, app: app))
        capability.tap()
        XCTAssertTrue(element(A11yID.arenaPremiumCapabilityDetail, in: app).waitForExistence(timeout: 10))
        capture(app, "arena-premium-04-capability")
        app.buttons["fechar capacidade"].tap()

        app.buttons[A11yID.arenaPremiumTab("agora")].tap()
        let stop = app.buttons[A11yID.arenaPremiumStop]
        XCTAssertTrue(stop.waitForExistence(timeout: 10))
        stop.tap()
        XCTAssertTrue(element(A11yID.arenaPremiumStopSheet, in: app).waitForExistence(timeout: 10))
        XCTAssertTrue(app.textFields[A11yID.arenaPremiumStopActor].exists)
        XCTAssertTrue(element(A11yID.arenaPremiumStopReason, in: app).exists)
        XCTAssertFalse(app.buttons[A11yID.arenaPremiumStopConfirm].isEnabled)
        capture(app, "arena-premium-05-stop")
    }

    @MainActor
    func testPremiumArenaNewMeasurementRequiresGovernance() {
        let app = XCUIApplication()
        app.launchArguments = ["-atlas.arena.scenario", "idle"]
        app.launch()

        XCTAssertTrue(element(A11yID.arenaPremiumState("idle"), in: app).waitForExistence(timeout: 20))
        app.buttons[A11yID.arenaPremiumAdd].tap()
        XCTAssertTrue(element(A11yID.arenaRunSheet, in: app).waitForExistence(timeout: 10))

        let submit = app.buttons[A11yID.arenaRunSubmit]
        XCTAssertTrue(submit.waitForExistence(timeout: 10))
        XCTAssertFalse(submit.isEnabled)
        capture(app, "arena-premium-02-new-measurement")

        let actor = app.textFields[A11yID.arenaRunActor]
        actor.tap()
        actor.typeText("uitest")
        let reason = element(A11yID.arenaRunReason, in: app)
        reason.tap()
        reason.typeText("comparação governada")
        XCTAssertTrue(submit.isEnabled)
        capture(app, "arena-premium-02-new-measurement-governed")
    }

    @MainActor
    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    @MainActor
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func scrollUntilVisible(_ element: XCUIElement, app: XCUIApplication) -> Bool {
        let deadline = Date().addingTimeInterval(12)
        while Date() < deadline {
            if element.exists && element.isHittable { return true }
            app.swipeUp()
        }
        return element.exists
    }
}

private extension XCUIElement {
    @MainActor
    func tapIfExists() {
        if waitForExistence(timeout: 2) { tap() }
    }
}
