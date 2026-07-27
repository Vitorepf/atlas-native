import XCTest

final class AtlasArenaNowProbeTests: XCTestCase {
    @MainActor
    func testEveryArenaLifecycleStateHasDistinctSemantics() {
        // O que se verifica é a VOZ do estado, não o texto visível.
        //
        // O subtítulo do hero carrega `.accessibilityLabel(nowFace.spokenFace)`
        // — padrão da casa: `product*` é lido, `spoken*` é falado, e no
        // VoiceOver o falado SUBSTITUI o visível. Este teste procurava o texto
        // de tela e por isso falhava em 4 dos 7 estados desde que o label foi
        // adicionado. Não era regressão: era o teste medindo o que o app não
        // promete naquela árvore.
        //
        // Descoberto em 27/07 ao rodar as 8 suítes que ficavam fora do
        // wrapper. Ver scripts/uitest.sh, que agora roda TODAS.
        let expected: [(scenario: String, state: String, spoken: String)] = [
            ("idle", "idle", "parada"),
            ("queued", "queued", "na fila"),
            ("running", "running", "ao vivo"),
            ("stopping", "stopping", "parando"),
            ("stopped", "stopped", "parada pelo operador"),
            ("completed", "completed", "concluída"),
            ("failed", "failed", "interrompida"),
        ]

        for item in expected {
            let app = XCUIApplication()
            app.launchArguments = ["-atlas.arena.scenario", item.scenario]
            app.launch()
            XCTAssertTrue(
                app.descendants(matching: .any)[A11yID.arenaPremiumState(item.state)]
                    .waitForExistence(timeout: 20),
                "estado \(item.state) não apareceu"
            )
            XCTAssertTrue(
                app.staticTexts[item.spoken].exists,
                "voz de \(item.state) divergiu — esperava \"\(item.spoken)\""
            )
            let shot = XCTAttachment(screenshot: app.screenshot())
            shot.name = "arena-state-\(item.state)"
            shot.lifetime = .keepAlways
            add(shot)
            app.terminate()
        }
    }
}
