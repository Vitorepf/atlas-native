import SwiftUI
import AtlasCore

/// Lista / loading / offline / empty — peel de WorkspaceView (régua ≤100).
/// Loaded → WorkspaceView+ScrollLoaded.swift
/// Failure → WorkspaceView+ScrollFailure.swift

extension WorkspaceView {
    var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if showsLoadingShell {
                    WorkspaceLoadingEmpty(reduceMotion: reduceMotion)
                        .accessibilityIdentifier(A11yID.workspaceLoading)
                } else if showsNetworkFailure {
                    listNetworkFailure
                } else {
                    listLoadedContent
                }
            }
            .padding(.bottom, 96)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: area)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: threads.map(\.id))
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }
}
