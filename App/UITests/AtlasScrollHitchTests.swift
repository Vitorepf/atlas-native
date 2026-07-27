import XCTest

/// Mede FLUIDEZ de rolagem — o gap que eu vinha declarando fora de alcance.
///
/// MEDIDO, E O RESULTADO CORRIGE A EXPECTATIVA (27/07):
///   com cache do grafo:  0,701s  (RSD 0,08%)
///   sem cache do grafo:  0,702s  (RSD 0,03%)
/// Ou seja: `scrollDecelerationMetric` mede a DURAÇÃO da desaceleração, que é
/// física da animação — não o custo de render. Ele NÃO distingue as 4,8
/// milhões de operações por frame que o cache eliminou.
///
/// Então este teste **não** responde "está fluido?". O que ele dá é um
/// baseline com desvio de 0,03–0,08%: qualquer regressão que trave a rolagem
/// de verdade (o "nada responde" que o operador relatou) sai desse envelope.
/// Hitch fino continua exigindo Instruments (Animation Hitches) no device —
/// e isso o XCUITest não alcança.
final class AtlasScrollHitchTests: XCTestCase {

    func testGraphScrollHitches() throws {
        let app = XCUIApplication()
        app.launch()

        let code = app.buttons[A11yID.topbarCode]
        XCTAssertTrue(code.waitForExistence(timeout: 45), "barra precisa expor o Código")
        code.tap()

        let repoCard = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", A11yID.radarRepoPrefix))
            .firstMatch
        guard repoCard.waitForExistence(timeout: 30) else {
            XCTFail("sem repo no radar — servidor fora, medição inválida")
            return
        }
        repoCard.tap()
        XCTAssertTrue(
            app.descendants(matching: .any)[A11yID.codeStatus].waitForExistence(timeout: 30),
            "o grafo precisa abrir"
        )

        // A lista do grafo é a mais longa do app (200 commits) — se hitch
        // existe em algum lugar, é aqui.
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            app.swipeUp(velocity: .fast)
        }
    }
}
