import SwiftUI
import UIKit

// Icon column — peel de ConversationChrome+ComposerSheets+AttachmentCopy.

extension ComposerAttachmentRow {
    var attachmentRowIcon: some View {
        Image(systemName: icon)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(AtlasTheme.accent)
            .frame(width: 28)
            .accessibilityHidden(true)
    }
}
