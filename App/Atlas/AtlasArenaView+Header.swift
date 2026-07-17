import SwiftUI
import AtlasCore

// Header ARENA — peel de AtlasArenaView.
// Age → AtlasArenaView+HeaderAge.swift
// TitleColumn → AtlasArenaView+Header+TitleColumn.swift
// A11yBind → AtlasArenaView+Header+A11yBind.swift

extension AtlasArenaView {
    var header: some View {
        headerA11yBound(headerTitleColumn)
    }
}
