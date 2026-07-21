import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

extension AtlasArenaView {
    func arenaLifecycleA11y<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Arena")
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension AtlasArenaView {
    func arenaLifecycleTasks<Content: View>(_ content: Content) -> some View {
        content
            .task {
                if case .idle = model.phase {
                    await model.load()
                }
            }
            .onAppear { model.setVisible(true) }
            .onDisappear { model.setVisible(false) }
            .refreshable { await model.load() }
    }
}

extension AtlasArenaView {
    func arenaLifecycleChrome<Content: View>(_ content: Content) -> some View {
        arenaLifecycleTasks(arenaLifecycleA11y(content))
    }
}

extension AtlasArenaView {
    func arenaSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showingRunSheet) {
                ArenaRunSheet(model: model)
            }
    }
}

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
    }
}
