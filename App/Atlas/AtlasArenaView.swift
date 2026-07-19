import SwiftUI
import AtlasCore

/// Arena — medição de regressão dos motores (canon).
/// Content/header → AtlasArenaView+* · Sheets → AtlasArenaView+Sheets.swift
/// Scroll → AtlasArenaView+ScrollBody.swift · Lifecycle → AtlasArenaView+Lifecycle.swift
struct AtlasArenaView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) var session
    @Bindable var model: ArenaModel
    @State var selectedSuite: AtlasArenaSuite?
    @State var selectedEngine: AtlasArenaCompositeEngine?
    @State var showingRunSheet = false
    @State var selectedTab: ArenaPremiumTab = .now
    @State var premiumDestination: ArenaPremiumDestination?
    @State var selectedCapability: AtlasArenaCapability?
    @State var stoppingRun: AtlasArenaLiveRun?
    /// Suítes são bastidor (capacidades são o palco): lista colapsada em uma
    /// linha; regressão fura o colapso.
    @State var suitesExpanded = false

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
    }
}
