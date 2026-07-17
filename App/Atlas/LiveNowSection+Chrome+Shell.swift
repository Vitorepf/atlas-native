import SwiftUI
import AtlasCore

// Section shell — peel de LiveNowSection+Chrome.
// Body → LiveNowSection+Chrome+Shell+Body.swift
// CardChrome → LiveNowSection+Chrome+Shell+CardChrome.swift

extension LiveNowSection {
    var liveNowSectionShell: some View {
        liveNowSectionCardChrome(liveNowSectionBody)
    }
}
