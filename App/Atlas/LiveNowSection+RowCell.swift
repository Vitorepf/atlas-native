import SwiftUI
import AtlasCore

// LiveNow row cell — peel de LiveNowSection+Rows.
// Transition → LiveNowSection+RowCell+Transition.swift
// Build → LiveNowSection+RowCell+Build.swift

extension LiveNowSection {
    func liveNowRowCell(index: Int, session: LiveSessionSnapshot) -> some View {
        liveNowRowTransition(liveNowRowBuild(index: index, session: session))
    }
}
