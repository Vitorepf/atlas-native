import SwiftUI
import AtlasCore

// Session rows — peel de LiveNowSection.
// Separator → LiveNowSection+RowSeparator.swift
// Cell → LiveNowSection+RowCell.swift

extension LiveNowSection {
    @ViewBuilder
    var liveNowRows: some View {
        ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
            if isHub, index > 0 {
                LiveNowRowSeparator.hub
            }
            liveNowRowCell(index: index, session: session)
        }
    }
}
