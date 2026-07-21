import SwiftUI
import AtlasCore

// Reject button label — peel de ChangeReviewRunActions+Reject.

extension ChangeReviewRunActions {
    var rejectButtonLabel: some View {
        Text("Rejeitar")
            .font(AtlasFont.mono(11, .semibold)).foregroundStyle(AtlasTheme.domOperacional)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
    }
}
