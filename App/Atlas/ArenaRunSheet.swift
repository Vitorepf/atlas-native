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
    @State var selectedEngine: String = ""
    @State var selectedArms: Set<AtlasArenaRunArm> = [.baseline, .withAtlas]
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        runSheetA11y(runNavShell)
    }
}
