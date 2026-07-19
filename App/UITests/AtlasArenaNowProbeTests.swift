import XCTest

final class AtlasArenaNowProbeTests: XCTestCase {
    @MainActor
    func testEveryArenaLifecycleStateHasDistinctSemantics() {
        let expected: [(scenario: String, state: String, copy: String)] = [
            ("idle", "idle", "Nada medindo agora"),
            ("queued", "queued", "Medição programada"),
            ("running", "running", "17/42 casos"),
            ("stopping", "stopping", "Finalizando o caso atual"),
            ("stopped", "stopped", "Resultados parciais preservados"),
            ("completed", "completed", "Resultado terminal confirmado"),
            ("failed", "failed", "O que concluiu foi preservado"),
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
            XCTAssertTrue(app.staticTexts[item.copy].exists, "copy de \(item.state) divergiu")
            let shot = XCTAttachment(screenshot: app.screenshot())
            shot.name = "arena-state-\(item.state)"
            shot.lifetime = .keepAlways
            add(shot)
            app.terminate()
        }
    }
}
