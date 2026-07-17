import SwiftUI
import AtlasCore

// Status → ArenaRunSheet+Status.swift
// Body → ArenaRunSheet+Body.swift
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
            runScrollBody
        }
        .onAppear { seedDefaultsIfNeeded() }
        .accessibilityIdentifier(A11yID.arenaRunSheet)
        .accessibilityLabel(spokenSheetLabel())
        .accessibilityHint(spokenSheetHint())
    }
}
