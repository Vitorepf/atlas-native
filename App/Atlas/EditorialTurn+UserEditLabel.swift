import SwiftUI
import AtlasCore

// User edit button label — peel de EditorialTurn+UserEdit.

extension EditorialTurn {
    var userEditResendLabel: some View {
        HStack(spacing: 5) {
            Image(systemName: "arrow.turn.down.right")
                .font(.system(size: 10, weight: .semibold))
                .accessibilityHidden(true)
            Text("editar e reenviar")
                .font(AtlasFont.mono(10))
        }
        .foregroundStyle(AtlasTheme.textTertiary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}
