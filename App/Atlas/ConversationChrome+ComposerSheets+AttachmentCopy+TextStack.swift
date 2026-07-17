import SwiftUI
import UIKit

// Text column — peel de ConversationChrome+ComposerSheets+AttachmentCopy.

extension ComposerAttachmentRow {
    var attachmentRowTextStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subtitle).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}
