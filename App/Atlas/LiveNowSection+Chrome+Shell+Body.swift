import SwiftUI
import AtlasCore

// Section body — peel de LiveNowSection+Chrome+Shell.
// Header → LiveNowSection+Chrome+Shell+Body+Header.swift
// Rows → LiveNowSection+Chrome+Shell+Body+Rows.swift

extension LiveNowSection {
    var liveNowSectionBody: some View {
        VStack(alignment: .leading, spacing: isHub ? 0 : 12) {
            liveNowSectionHeaderBlock
            liveNowSectionRowsBlock
        }
    }
}
