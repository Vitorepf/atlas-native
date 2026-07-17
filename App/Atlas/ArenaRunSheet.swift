import SwiftUI
import AtlasCore

// Status → ArenaRunSheet+Status.swift
struct ArenaRunSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Bindable var model: ArenaModel
    @State var selectedSuites: Set<String> = []
    @State var selectedEngine: String = ""
    @State var selectedArms: Set<AtlasArenaRunArm> = [.baseline, .withAtlas]
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    formSections
                    statusBlocks
                    submitButton
                }
                .padding(AtlasTheme.Space.screen)
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.lastStartReceipt?.receiptHash)
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.controlError)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Rodar medição")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { runToolbar }
        }
        .onAppear { seedDefaultsIfNeeded() }
        .accessibilityIdentifier(A11yID.arenaRunSheet)
        .accessibilityLabel(spokenSheetLabel())
        .accessibilityHint(spokenSheetHint())
    }
}
