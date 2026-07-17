import SwiftUI
import AtlasCore

// LazyVStack do corpo Autônomos — peel de AutonomosLoadedSection (régua ≤100).
// Head → +StackHead.swift · Tail → +StackTail.swift
// Area → AutonomosLoadedSection+StackArea.swift
// Mid → AutonomosLoadedSection+StackMid.swift

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStack: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            loadedStackHead
            loadedStackMid
            loadedStackTail
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 10).padding(.bottom, 32)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: receiptPhaseID)
    }
}
