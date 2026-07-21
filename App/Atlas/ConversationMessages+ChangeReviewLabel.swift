import SwiftUI
import AtlasCore

// Change-review chip label — peel de ConversationMessages+ChangeReview.

extension ConversationMessages {
    var changeReviewChipLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "plus.forwardslash.minus").atlasSans(11)
            Text("Revisar mudanças").font(.system(.footnote, weight: .medium))
        }
        .foregroundStyle(AtlasTheme.textSecondary)
        .padding(.horizontal, 13).padding(.vertical, 7)
        .background(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}
