import SwiftUI
import AtlasCore

// Steer button label — peel de ExecutionStateCard+SteerRetry.

extension ExecutionStateCard {
    var steerButtonLabel: some View {
        Text("Redirecionar")
            .font(.system(.caption, weight: .semibold))
            .lineLimit(1)
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity)
    }
}
