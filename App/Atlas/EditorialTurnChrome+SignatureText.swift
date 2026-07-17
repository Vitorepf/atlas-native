import SwiftUI

// Signature text helpers — peel de EditorialTurnChrome+Signature.

extension SignatureLine {
    func revealSignature() {
        if reduceMotion { shown = true; return }
        Task {
            try? await Task.sleep(nanoseconds: 220_000_000)
            withAnimation(.easeIn(duration: 0.28)) { shown = true }
        }
    }

    var signature: String {
        let who = signatureWho
        if let ms = elapsedMs, ms > 0 { return "— \(who), em \(humanDuration(ms))" }
        return "— \(who)"
    }

    var signatureWho: String {
        if let model, !model.isEmpty, !model.hasSuffix("_default") { return model }
        let word = providerWord(provider)
        return word.isEmpty ? "provedor não publicado" : word
    }
}
