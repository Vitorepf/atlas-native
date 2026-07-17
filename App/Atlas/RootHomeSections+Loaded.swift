import SwiftUI
import AtlasCore

// Loaded home scroll — peel de RootHomeSections.
// Conversas → +Conversas · Operação → +Operacao
// Stack → RootHomeSections+LoadedStack.swift

extension RootHomeSections {
    @ViewBuilder
    var loadedHome: some View {
        ScrollView {
            loadedHomeStack
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }
}
