import SwiftUI
import AtlasCore

// Stack de seções do home carregado — peel de RootHomeSections+Loaded.
// LiveNow → RootHomeSections+LoadedLiveNow.swift

extension RootHomeSections {
    @ViewBuilder
    var loadedHomeStack: some View {
        LazyVStack(spacing: 0) {
            liveNowSectionIfNeeded
            conversasSection
            rowDivider
            operacaoSection
            if showsWorkspacesSection {
                rowDivider
                workspacesSection
            }
        }
        .padding(.bottom, 96)
    }
}
