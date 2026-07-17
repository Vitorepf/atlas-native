import SwiftUI
import AtlasCore

/// Arena — medição de regressão dos motores (canon).
/// Content/header → AtlasArenaView+* · Sheets → AtlasArenaView+Sheets.swift
/// Scroll → AtlasArenaView+ScrollBody.swift
struct AtlasArenaView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(AtlasSession.self) var session
    @Bindable var model: ArenaModel
    @State var selectedSuite: AtlasArenaSuite?
    @State var selectedEngine: AtlasArenaCompositeEngine?
    @State var showingRunSheet = false

    var body: some View {
        arenaSheets(on:
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                arenaScrollBody
            }
            .navigationTitle("Arena")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier(A11yID.arenaScreen)
            .accessibilityLabel(spokenArenaScreenLabel())
            .accessibilityHint(
                model.isDomainUnavailable && model.composite == nil
                    ? domainUnavailableHint
                    : "medição de regressão dos motores"
            )
            .task {
                if case .idle = model.phase {
                    await model.load()
                }
            }
            .onAppear { model.setVisible(true) }
            .onDisappear { model.setVisible(false) }
            .refreshable { await model.load() }
        )
    }
}
