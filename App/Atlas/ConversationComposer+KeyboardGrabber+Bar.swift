import SwiftUI
import AtlasCore

// Grabber bar shape — peel de ConversationComposer+KeyboardGrabber.

extension ConversationComposer {
    var keyboardGrabberBar: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AtlasTheme.textTertiary.opacity(0.55))
            .frame(width: 42, height: 5)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
    }
}
