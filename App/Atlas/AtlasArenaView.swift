import AtlasCore
import SwiftUI

// Cycle 044 fuse → AtlasArenaView.swift

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

extension AtlasArenaView {
    func arenaLifecycleA11y<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Arena")
            .navigationBarTitleDisplayMode(.inline)
            // O título de navegação já anuncia a superfície. Label/ID no
            // container inteiro substituía o nome e o ID de cada tab e CTA.
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

// Sheets live da Arena premium (Run + Suite). Engine sheet classic removido.

extension AtlasArenaView {
    func arenaSheets<Content: View>(on content: Content) -> some View {
        content
            // Suite sheet vive no ArenaPremiumShell (estado local) — evita
            // sheet(item:) órfão no contentor que não reapresentava no iOS 26.
            .sheet(isPresented: $showingRunSheet) {
                ArenaRunSheet(model: model)
            }
    }
}
