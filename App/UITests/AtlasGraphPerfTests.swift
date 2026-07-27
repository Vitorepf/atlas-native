import XCTest

/// A tela do Grafo travava por segundos a cada toque e o tour não a cobria —
/// ele fotografava telas paradas e nunca media INTERAÇÃO. Este teste mede.
///
/// Causa medida em 27/07: `violatingHashes`/`healedHashes` eram computed
/// properties O(violações × nós), lidas 3× por linha por `state(for:)`. Com
/// 200 commits e 40 violações davam ~4,8 milhões de comparações por
/// renderização, refeitas a cada scroll.
final class AtlasGraphPerfTests: XCTestCase {

    func testGraphScrollStaysResponsive() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()

        let code = app.buttons[A11yID.topbarCode]
        XCTAssertTrue(code.waitForExistence(timeout: 30), "barra precisa expor o Código")
        code.tap()

        let repoCard = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", A11yID.radarRepoPrefix))
            .firstMatch
        guard repoCard.waitForExistence(timeout: 25) else {
            XCTFail("sem repo no radar — servidor fora, medição inválida")
            return
        }

        let abertura = Date()
        repoCard.tap()
        let status = app.descendants(matching: .any)[A11yID.codeStatus]
        XCTAssertTrue(status.waitForExistence(timeout: 30), "o grafo precisa abrir")
        let tempoAbertura = Date().timeIntervalSince(abertura)

        // Rolagem: é aqui que o custo por linha aparecia. Seis passadas.
        let rolagem = Date()
        for _ in 0..<6 { app.swipeUp() }
        let tempoRolagem = Date().timeIntervalSince(rolagem)

        let media = tempoRolagem / 6
        print("GRAFO · abertura \(String(format: "%.2f", tempoAbertura))s · "
              + "scroll médio \(String(format: "%.2f", media))s")

        // O operador relatou >10s por interação. Um swipe que passe de 1,5s
        // já é inaceitável; o limite existe para a regressão falhar, não para
        // celebrar o número de hoje.
        XCTAssertLessThan(media, 1.5, "cada rolagem do grafo precisa ficar abaixo de 1,5s")
        XCTAssertLessThan(tempoAbertura, 12, "abrir o grafo precisa ficar abaixo de 12s")
    }
}
