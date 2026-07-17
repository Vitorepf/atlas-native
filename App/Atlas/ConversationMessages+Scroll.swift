import SwiftUI
import AtlasCore

// FAB + scroll coalescing — peel de ConversationMessages.

extension ConversationMessages {
    @ViewBuilder
    func scrollChrome<Content: View>(proxy: ScrollViewProxy, @ViewBuilder content: () -> Content) -> some View {
        content()
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onPreferenceChange(BottomDistanceKey.self) { minY in
                awayFromBottom = minY > UIScreen.main.bounds.height + 140
            }
            .overlay(alignment: .bottomTrailing) {
                if awayFromBottom {
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    } label: {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AtlasTheme.surfaceHi)
                                .overlay(Circle().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                                .shadow(color: .black.opacity(0.25), radius: 8, y: 2))
                    }
                    .buttonStyle(PressableScale())
                    .padding(.trailing, AtlasTheme.Space.screen).padding(.bottom, 110)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .accessibilityLabel("ir para o fim da conversa")
                }
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: awayFromBottom)
            .onChange(of: model.bubbles) {
                let count = model.bubbles.count
                let now = CFAbsoluteTimeGetCurrent()
                let countChanged = count != lastScrollBubbleCount
                guard countChanged || now - lastScrollAt >= 0.1 else { return }
                lastScrollAt = now
                lastScrollBubbleCount = count
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
    }
}

private struct BottomDistanceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
