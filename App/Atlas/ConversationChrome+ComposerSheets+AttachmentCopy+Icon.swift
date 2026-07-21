import SwiftUI
import UIKit

// Icon column — peel de ConversationChrome+ComposerSheets+AttachmentCopy.

extension ComposerAttachmentRow {
    var attachmentRowIcon: some View {
        Image(systemName: icon)
            .atlasSans(17, .medium)
            .foregroundStyle(AtlasTheme.accent)
            .frame(width: 28)
            .accessibilityHidden(true)
    }
}
