import SwiftUI
import AtlasCore

// User edit button label — peel de EditorialTurn+UserEdit.

extension EditorialTurn {
    var userEditResendLabel: some View {
        HStack(spacing: 5) {
            Image(systemName: "arrow.turn.down.right")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            // Ação fala em sans (mono é hash/recibo/meta — canon §C);
            // secondary dá affordance de ação sem gritar.
            Text("editar e reenviar")
                .atlasSans(11, .medium)
        }
        .foregroundStyle(AtlasTheme.textSecondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}
