import XCTest

/// Mede a abertura de TODAS as superfícies, não só a que o operador reclamou.
///
/// O tour fotografa telas paradas — foi por isso que o Grafo travando por
/// segundos passou despercebido até o operador sentir no device. Este teste
/// existe para a próxima lentidão aparecer aqui antes de aparecer na mão dele.
///
/// Não afirma "está rápido": imprime o número de cada tela e falha só no que
/// é indefensável. O julgamento fino continua sendo do operador, no aparelho.
final class AtlasSurfacePerfTests: XCTestCase {

    /// Acima disto a tela parece travada ao toque.
    private let limite: TimeInterval = 3.0

    func testEverySurfaceOpensFast() {
        continueAfterFailure = true
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.buttons[A11yID.homeInputPill].waitForExistence(timeout: 45),
            "home não abriu"
        )

        var medidas: [(String, TimeInterval)] = []
        var lentas: [String] = []

        func medir(_ nome: String, abrir: () -> Void, chegou: () -> Bool) {
            let t0 = Date()
            abrir()
            let ok = chegou()
            let dt = Date().timeIntervalSince(t0)
            medidas.append((nome, dt))
            if !ok { lentas.append("\(nome) (não abriu)") }
            else if dt > limite { lentas.append("\(nome) \(String(format: "%.2f", dt))s") }
        }

        // Relançar é determinístico onde voltar não é: swipe de borda e botão
        // de nav se comportam diferente por superfície.
        func voltarParaHome() {
            app.terminate()
            app.launch()
            _ = app.buttons[A11yID.homeInputPill].waitForExistence(timeout: 45)
        }

        medir("Conversas livres") {
            app.buttons[A11yID.homeConversasEntry].tap()
        } chegou: {
            app.descendants(matching: .any)[A11yID.workspaceScreen].waitForExistence(timeout: 20)
        }
        voltarParaHome()

        medir("Arena") {
            app.buttons[A11yID.arenaHomeEntry].tap()
        } chegou: {
            app.buttons[A11yID.arenaPremiumTab("frota")].waitForExistence(timeout: 25)
        }
        for aba in ["frota", "capacidades", "motor"] {
            let tab = app.buttons[A11yID.arenaPremiumTab(aba)]
            guard tab.exists, tab.isHittable else { continue }
            let t0 = Date()
            tab.tap()
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 15)
            let dt = Date().timeIntervalSince(t0)
            medidas.append(("Arena · \(aba)", dt))
            if dt > limite { lentas.append("Arena · \(aba) \(String(format: "%.2f", dt))s") }
        }
        voltarParaHome()

        medir("Código · radar") {
            app.buttons[A11yID.topbarCode].tap()
        } chegou: {
            app.descendants(matching: .any)
                .matching(NSPredicate(format: "identifier BEGINSWITH %@", A11yID.radarRepoPrefix))
                .firstMatch.waitForExistence(timeout: 25)
        }

        medir("Código · grafo") {
            app.descendants(matching: .any)
                .matching(NSPredicate(format: "identifier BEGINSWITH %@", A11yID.radarRepoPrefix))
                .firstMatch.tap()
        } chegou: {
            app.descendants(matching: .any)[A11yID.codeStatus].waitForExistence(timeout: 30)
        }

        print("── ABERTURA POR SUPERFÍCIE ──")
        for (nome, dt) in medidas {
            print(String(format: "%-24s %.2fs", (nome as NSString).utf8String!, dt))
        }

        XCTAssertTrue(
            lentas.isEmpty,
            "superfícies acima de \(limite)s: \(lentas.joined(separator: " · "))"
        )
    }
}
