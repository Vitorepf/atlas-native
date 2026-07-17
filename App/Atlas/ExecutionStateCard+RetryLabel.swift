import SwiftUI
import AtlasCore

// Label do retry — peel de ExecutionStateCard+Retry.

extension ExecutionStateCard {
    var retryFallbackLabel: some View {
        Text("Retomar")
            .font(.system(.caption, weight: .semibold))
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }
}
