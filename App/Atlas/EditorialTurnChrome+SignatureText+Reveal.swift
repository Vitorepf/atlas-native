import SwiftUI

// Reveal animation — peel de EditorialTurnChrome+SignatureText.

extension SignatureLine {
    func revealSignature() {
        if reduceMotion { shown = true; return }
        Task {
            try? await Task.sleep(nanoseconds: 220_000_000)
            withAnimation(.easeIn(duration: 0.28)) { shown = true }
        }
    }
}
