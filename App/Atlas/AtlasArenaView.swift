import AtlasCore
import SwiftUI

// Cycle 041 fuse → AtlasArenaView.swift

/// Arena — medição de motores (premium only). Dual-stack classic removido (GOD F5).
struct AtlasArenaView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) var session
    @Bindable var model: ArenaModel
    @State var selectedSuite: AtlasArenaSuite?
    @State var showingRunSheet = false
    @State var selectedTab: ArenaPremiumTab = .now
    @State var premiumDestination: ArenaPremiumDestination?
    @State var selectedCapability: AtlasArenaCapability?
    @State var stoppingRun: AtlasArenaLiveRun?

    var body: some View {
        arenaSheets(on:
            arenaLifecycleChrome(
                ArenaPremiumShell(
                    model: model,
                    selectedTab: $selectedTab,
                    destination: $premiumDestination,
                    selectedSuite: $selectedSuite,
                    selectedCapability: $selectedCapability,
                    showingRunSheet: $showingRunSheet,
                    stoppingRun: $stoppingRun
                )
            )
        )
        // NÃO colocar accessibilityIdentifier/label no container da Arena —
        // no iOS 26 isso substitui o id de cada tab/CTA (todos viram
        // "arena-screen") e quebra a bateria XCUITest.
    }
}
