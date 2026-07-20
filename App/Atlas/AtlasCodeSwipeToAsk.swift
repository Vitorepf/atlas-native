import SwiftUI

// Gesto agêntico: arrastar a linha → pergunta sobre o commit.
// LazyVStack não tem swipeActions; drag horizontal dominante abre o ask.

struct AtlasCodeSwipeToAsk: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let action: () -> Void
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .simultaneousGesture(
                DragGesture(minimumDistance: 28)
                    .onChanged { value in
                        let dx = value.translation.width
                        let dy = value.translation.height
                        guard abs(dx) > abs(dy), dx < 0 else { return }
                        offset = max(dx, -72)
                    }
                    .onEnded { value in
                        let shouldAsk = value.translation.width < -56
                        let reset = {
                            offset = 0
                        }
                        if reduceMotion {
                            reset()
                        } else {
                            withAnimation(.easeOut(duration: 0.18), reset)
                        }
                        if shouldAsk { action() }
                    }
            )
    }
}

extension View {
    func atlasSwipeToAsk(perform action: @escaping () -> Void) -> some View {
        modifier(AtlasCodeSwipeToAsk(action: action))
    }
}
