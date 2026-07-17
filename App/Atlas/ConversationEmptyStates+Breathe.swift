import SwiftUI
import AtlasCore

// Breathe — peel de EmptyConversation suggestions.

extension EmptyConversation {
    func startBreathing() {
        if !reduceMotion {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }
}
