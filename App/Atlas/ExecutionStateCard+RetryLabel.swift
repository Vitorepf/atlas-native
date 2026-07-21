import SwiftUI
import AtlasCore

// Label do retry — peel de ExecutionStateCard+Retry.

extension ExecutionStateCard {
    var retryFallbackLabel: some View {
        Text("Retomar")
            .font(AtlasFont.mono(10, .semibold))
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }
}
