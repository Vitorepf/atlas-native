import XCTest

/// Tour de design — captura as superfícies principais com dados reais para a
/// crítica visual do polimento (casca). Não afirma conteúdo: só navega e
/// fotografa; a prova de comportamento vive nos testes dedicados.
final class AtlasDesignTourTests: XCTestCase {

    func testDesignTourCaptures() {
        continueAfterFailure = false
        // Diálogo de deep link pendente de sessão anterior cobre o app.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let home = app.buttons[A11yID.homeInputPill]
        XCTAssertTrue(home.waitForExistence(timeout: 45), "home não abriu")
        attach(app, name: "tour-01-home")

        let autonomos = app.buttons[A11yID.homeAutonomosEntry]
        XCTAssertTrue(autonomos.waitForExistence(timeout: 20), "home precisa expor Autônomos")
        autonomos.tap()

        let line = app.buttons[A11yID.autonomosRhythmLine]
        _ = line.waitForExistence(timeout: 45)
        attach(app, name: "tour-02-autonomos-topo")

        app.swipeUp()
        attach(app, name: "tour-03-autonomos-meio")
        app.swipeUp()
        attach(app, name: "tour-04-autonomos-frota")
        app.swipeUp()
        attach(app, name: "tour-05-autonomos-fim")

        if line.exists && line.isHittable {
            line.tap()
            if app.staticTexts["O ritmo do seu dia"].waitForExistence(timeout: 8) {
                attach(app, name: "tour-06-folha-ritmo")
            }
            app.swipeDown()
        }
    }

    func testDesignTourArena() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let arena = app.buttons[A11yID.arenaHomeEntry]
        XCTAssertTrue(arena.waitForExistence(timeout: 45), "home precisa expor a Arena")
        attach(app, name: "arena-00-home")
        arena.tap()
        sleep(3)
        attach(app, name: "arena-01-topo")
        app.swipeUp()
        attach(app, name: "arena-02-meio")
        app.swipeUp()
        attach(app, name: "arena-03-fim")
    }

    func testDesignTourConversa() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        // Conversa nova (composer vazio — estado inicial é design também).
        let pill = app.buttons[A11yID.homeInputPill]
        XCTAssertTrue(pill.waitForExistence(timeout: 45), "home não abriu")
        pill.tap()
        // A pílula abre o picker; "Sem repositório" leva à conversa em branco.
        let semRepo = app.buttons[A11yID.workspacePickerNoRepo]
        if semRepo.waitForExistence(timeout: 10) { semRepo.tap() }
        sleep(2)
        attach(app, name: "conversa-01-nova")
        // Overlay de tutorial do teclado do simulador rouba toques — relançar
        // é determinístico onde navegar de volta não é.
        app.terminate()
        app.launch()
        XCTAssertTrue(pill.waitForExistence(timeout: 30), "home não voltou após relaunch")

        // Conversa existente com conteúdo real: primeiro workspace da home.
        let freeList = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", A11yID.homeWorkspacePrefix)
        ).firstMatch
        if freeList.waitForExistence(timeout: 10) {
            freeList.tap()
            sleep(2)
            attach(app, name: "conversa-02-lista")
            let firstThread = app.buttons.matching(
                NSPredicate(format: "identifier BEGINSWITH %@", A11yID.workspaceThreadPrefix)
            ).firstMatch
            let target = firstThread.exists ? firstThread : app.cells.firstMatch
            if target.waitForExistence(timeout: 10) {
                target.tap()
                sleep(3)
                attach(app, name: "conversa-03-thread")
                app.swipeDown()
                attach(app, name: "conversa-04-thread-historico")
            }
        }
    }

    func testDesignTourCodigo() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let code = app.buttons[A11yID.topbarCode]
        XCTAssertTrue(code.waitForExistence(timeout: 45), "home precisa expor o Atlas Código")
        code.tap()
        sleep(3)
        attach(app, name: "codigo-01-topo")
        app.swipeUp()
        attach(app, name: "codigo-02-meio")
        app.swipeUp()
        attach(app, name: "codigo-03-fim")
    }

    func testDesignTourAddWorkspace() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let add = app.buttons[A11yID.homeAddWorkspace]
        XCTAssertTrue(add.waitForExistence(timeout: 45), "home precisa expor Adicionar workspace")
        attach(app, name: "addws-00-home")
        // Em Dynamic Type grande a linha fica no fim da lista, atrás da
        // pílula. Um humano rola até ela; o XCUITest não rola sozinho e
        // acabava tocando na pílula. Rolar aqui testa o app, não o harness.
        if !add.isHittable { app.swipeUp() }
        XCTAssertTrue(add.isHittable, "Adicionar workspace precisa ficar alcançável após rolar")
        add.tap()
        let sheet = app.descendants(matching: .any)[A11yID.workspacePickerSheet]
        XCTAssertTrue(sheet.waitForExistence(timeout: 10), "picker precisa abrir")
        let row = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH %@", A11yID.workspacePickerRowPrefix)
        ).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 20), "picker precisa listar os repos do Mac")
        attach(app, name: "addws-01-picker")
    }

    func testDesignTourPerfil() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let profile = app.buttons[A11yID.topbarProfile]
        XCTAssertTrue(profile.waitForExistence(timeout: 45), "home precisa expor o perfil")
        attach(app, name: "perfil-00-home")
        profile.tap()
        let sheet = app.descendants(matching: .any)[A11yID.profileSheet]
        XCTAssertTrue(sheet.waitForExistence(timeout: 10), "perfil precisa abrir")
        sleep(1)
        attach(app, name: "perfil-01-sheet")
    }

    func testDesignTourSearchAndWorkspace() {
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
        sleep(2)
        attach(app, name: "search-01-vazia")
        app.typeText("atlas")
        sleep(2)
        attach(app, name: "search-02-resultados")

        app.terminate()
        app.launch()
        let workspace = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", A11yID.homeWorkspacePrefix)
        ).firstMatch
        XCTAssertTrue(workspace.waitForExistence(timeout: 45), "home precisa expor um workspace")
        workspace.tap()
        sleep(3)
        attach(app, name: "workspace-01-lista")
        app.swipeUp()
        attach(app, name: "workspace-02-meio")
    }

    func testDesignTourConversasLivres() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let entry = app.buttons[A11yID.homeConversasEntry]
        XCTAssertTrue(entry.waitForExistence(timeout: 45), "home precisa expor Conversas livres")
        entry.tap()
        sleep(3)
        attach(app, name: "livres-01-lista")
    }

    /// As abas Frota/Capacidades/Motor nunca tinham sido fotografadas — só a
    /// "Agora" aparecia no tour, e o que não é visto não é revisado.
    func testDesignTourArenaTabs() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let arena = app.buttons[A11yID.arenaHomeEntry]
        XCTAssertTrue(arena.waitForExistence(timeout: 45), "home precisa expor a Arena")
        arena.tap()
        sleep(3)

        for key in ["frota", "capacidades", "motor"] {
            let tab = app.buttons[A11yID.arenaPremiumTab(key)]
            guard tab.waitForExistence(timeout: 12), tab.isHittable else { continue }
            tab.tap()
            sleep(2)
            attach(app, name: "arena-aba-\(key)")
            app.swipeUp()
            attach(app, name: "arena-aba-\(key)-rolado")
        }
    }

    /// O tour antigo parava na folha de área e fotografava a mesma sheet 4×.
    /// Fecha a folha primeiro e desce o hub de verdade.
    func testDesignTourAutonomosHub() {
        continueAfterFailure = false
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.buttons["Cancelar"].waitForExistence(timeout: 3) {
            springboard.buttons["Cancelar"].tap()
        }
        let app = XCUIApplication()
        app.launch()

        let autonomos = app.buttons[A11yID.homeAutonomosEntry]
        XCTAssertTrue(autonomos.waitForExistence(timeout: 45), "home precisa expor Autônomos")
        autonomos.tap()
        sleep(3)

        // A folha de área abre por cima e escondia o hub inteiro no tour
        // antigo. O botão fala por accessibilityLabel, não pelo título.
        let close = app.buttons[A11yID.autonomosAreaBindClose]
        if close.waitForExistence(timeout: 8), close.isHittable {
            close.tap()
            sleep(1)
        }
        XCTAssertFalse(
            app.descendants(matching: .any)[A11yID.autonomosAreasSheet].exists,
            "a folha de área precisa sair da frente do hub"
        )
        attach(app, name: "hub-01-topo")
        for (index, name) in ["hub-02-meio", "hub-03-frota", "hub-04-fim"].enumerated() {
            _ = index
            app.swipeUp()
            sleep(1)
            attach(app, name: name)
        }
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
