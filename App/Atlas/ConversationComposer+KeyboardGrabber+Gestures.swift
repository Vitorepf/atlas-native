import SwiftUI
import AtlasCore

// Grabber gestures + a11y — peel de ConversationComposer+KeyboardGrabber.

extension ConversationComposer {
    func keyboardGrabberGestures<V: View>(_ bar: V) -> some View {
        bar
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
