import SwiftUI

// Signature copy — peel de EditorialTurnChrome+SignatureText.

extension SignatureLine {
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
