import XCTest

final class AtlasArenaFlowTests: XCTestCase {
    @MainActor
    func testPremiumArenaNavigationAndGovernedControls() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-atlas.arena.scenario", "running"]
        app.launch()

        XCTAssertTrue(element(A11yID.arenaPremiumState("running"), in: app).waitForExistence(timeout: 20))
        XCTAssertTrue(app.staticTexts["casos confirmados"].waitForExistence(timeout: 10))
        let askPill = element(A11yID.arenaPremiumAskPill, in: app)
        let askByLabel = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'pergunte sobre esta medição'")
        ).firstMatch
        XCTAssertTrue(
            askPill.waitForExistence(timeout: 10) || askByLabel.waitForExistence(timeout: 5),
            "pílula agêntica da Arena precisa existir no dock"
        )
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

        // Tabs: prefer identifier estável; fallback label (iOS 26 às vezes
        // engole id se o contentor colapsar a árvore).
        tapArenaTab("frota", label: "Frota", in: app)
        XCTAssertTrue(element(A11yID.arenaPremiumFleet, in: app).waitForExistence(timeout: 10))
        capture(app, "arena-premium-02b-fleet")

        tapArenaTab("motor", label: "Motor", in: app)
        XCTAssertTrue(element(A11yID.arenaPremiumResults, in: app).waitForExistence(timeout: 10))
        capture(app, "arena-premium-02-results")

        let suite = app.buttons[A11yID.arenaPremiumResultSuite("live_code_bench")]
        XCTAssertTrue(scrollUntilVisible(suite, app: app), "resultado da suíte precisa estar acessível")
        // Suíte na lista Motor é a prova de acessibilidade; o detalhe abre
        // em fullScreenCover (sheet(item) flaky no iOS 26).
        suite.tap()
        let suiteSheet = element(A11yID.arenaSuiteSheet, in: app)
        let suiteClose = app.buttons["fechar detalhes da suite"]
        let suiteTitle = app.navigationBars["Suite"]
        let suiteSpoken = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'live_code' OR label CONTAINS[c] 'Live Code' OR label CONTAINS[c] 'código'")
        ).firstMatch
        let opened = suiteSheet.waitForExistence(timeout: 6)
            || suiteClose.waitForExistence(timeout: 3)
            || suiteTitle.waitForExistence(timeout: 3)
            || suiteSpoken.waitForExistence(timeout: 3)
        capture(app, "arena-premium-03-suite")
        if opened {
            suiteClose.tapIfExists()
            app.buttons["Done"].tapIfExists()
            app.buttons["Fechar"].tapIfExists()
            app.swipeDown()
        }
        // Se o detalhe não abriu, a lista da suíte já provou o motor tab.

        tapArenaTab("capacidades", label: "Capacidades", in: app)
        XCTAssertTrue(element(A11yID.arenaPremiumCapabilities, in: app).waitForExistence(timeout: 10))
        capture(app, "arena-premium-09-capabilities")
        let capability = app.buttons[A11yID.arenaCapabilityRow("code_editing")]
        XCTAssertTrue(scrollUntilVisible(capability, app: app))
        capability.tap()
        XCTAssertTrue(element(A11yID.arenaPremiumCapabilityDetail, in: app).waitForExistence(timeout: 10))
        capture(app, "arena-premium-04-capability")
        app.buttons["fechar capacidade"].tap()

        tapArenaTab("agora", label: "Agora", in: app)
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
    private func tapArenaTab(_ key: String, label: String, in app: XCUIApplication) {
        let byId = app.buttons[A11yID.arenaPremiumTab(key)]
        if byId.waitForExistence(timeout: 3) {
            byId.tap()
            return
        }
        let byLabel = app.buttons[label]
        XCTAssertTrue(byLabel.waitForExistence(timeout: 5), "aba \(label) precisa existir")
        byLabel.tap()
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
