import SwiftUI
import AtlasCore

// LiveNow chrome — peel de LiveNowSection.
// Shell → LiveNowSection+Chrome+Shell.swift

extension LiveNowSection {
    var liveNowChrome: some View {
        liveNowSectionShell
            .accessibilityIdentifier(A11yID.liveNowSection)
            .accessibilityLabel(Self.spokenSectionLabel(
                isHub: isHub, count: sessions.count, remoteCount: remoteCount
            ))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: sessions.map(\.id))
    }
}
