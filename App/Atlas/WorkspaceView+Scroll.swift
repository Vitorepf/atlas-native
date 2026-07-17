import SwiftUI
import AtlasCore

/// Lista / loading / offline / empty — peel de WorkspaceView (régua ≤100).
/// Loaded → WorkspaceView+ScrollLoaded.swift
/// Failure → WorkspaceView+ScrollFailure.swift
/// Chrome → WorkspaceView+ScrollChrome.swift

extension WorkspaceView {
    var listView: some View {
        ScrollView {
            workspaceListChrome(
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
            )
        }
        .scrollIndicators(.hidden)
        .refreshable { await session.loadThreads() }
    }
}
