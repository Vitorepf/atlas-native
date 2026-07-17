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

    var body: some View {
        arenaSheets(on:
            arenaLifecycleChrome(
                ZStack {
                    AtlasTheme.bg.ignoresSafeArea()
                    arenaScrollBody
                }
            )
        )
    }
}
