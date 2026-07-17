import SwiftUI
import AtlasCore

// Keyboard grabber — peel de ConversationComposer+QueueGrabber.

extension ConversationComposer {
    @ViewBuilder
    var keyboardGrabber: some View {
        if focused.wrappedValue {
            RoundedRectangle(cornerRadius: 3)
                .fill(AtlasTheme.textTertiary.opacity(0.55))
                .frame(width: 42, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .contentShape(Rectangle())
                .onTapGesture { dismissKeyboard() }
                .gesture(
                    DragGesture(minimumDistance: 6)
                        .onEnded { if $0.translation.height > 8 { dismissKeyboard() } }
                )
                .accessibilityLabel("fechar teclado")
                .accessibilityHint("toque ou arraste para baixo para dispensar o teclado")
                .accessibilityAddTraits(.isButton)
        }
    }
}
