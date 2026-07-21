import SwiftUI
import AtlasCore

// Status → ArenaRunSheet+Status.swift
// Body → ArenaRunSheet+Body.swift
// Nav → ArenaRunSheet+NavShell.swift · A11y → ArenaRunSheet+SheetA11y.swift
struct ArenaRunSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Bindable var model: ArenaModel
    @State var selectedSuites: Set<String> = []
    /// Multi-select (goal 1: motor contra motor) — cada motor vira um POST B5.
    @State var selectedEngines: Set<String> = []
    @State var selectedArms: Set<AtlasArenaRunArm> = [.baseline, .withAtlas]
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        runSheetA11y(runNavShell)
    }
}
