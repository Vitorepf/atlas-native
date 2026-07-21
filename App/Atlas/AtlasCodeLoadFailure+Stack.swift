import SwiftUI

// Failure stack — peel de AtlasCodeLoadFailure.

extension AtlasCodeLoadFailureEmpty {
    var failureStack: some View {
        VStack(spacing: 14) {
            failureIcon
            failureHeadline
            failureMessage
            retryButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
