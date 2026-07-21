import SwiftUI
import UIKit
import AtlasCore

// Label visual do FAB — peel de ConversationMessages+ScrollFAB.

extension ConversationMessages {
    var scrollFABLabel: some View {
        Image(systemName: "arrow.down")
            .atlasSans(15, .semibold)
            .foregroundStyle(AtlasTheme.textPrimary)
            .frame(width: 40, height: 40)
            .background(Circle().fill(AtlasTheme.surfaceHi)
                .overlay(Circle().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                .shadow(color: .black.opacity(0.25), radius: 8, y: 2))
    }
}
