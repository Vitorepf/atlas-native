import SwiftUI
import AtlasCore

// Body copy — peel de AtlasNetworkFailureEmpty.
// Text → WorkspaceEmptyStates+FailureCopyText.swift

extension AtlasNetworkFailureEmpty {
    var failureCopyBlock: some View {
        VStack(spacing: 0) {
            failureCopyText
            if hasToken {
                Spacer().frame(height: 28)
                retryButton
            }
        }
    }
}
