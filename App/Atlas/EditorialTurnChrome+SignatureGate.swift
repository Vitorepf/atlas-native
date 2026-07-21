import SwiftUI

// Signature gate — peel de EditorialTurnChrome+Signature.

extension SignatureLine {
    /// Modelo ou provider reais — nunca fabrica «atlas» quando o contrato não publica quem respondeu.
    static func shouldDisplay(provider: String?, model: String?) -> Bool {
        let hasModel = model.map { !$0.isEmpty && !$0.hasSuffix("_default") } ?? false
        let hasProvider = provider.map { !$0.isEmpty } ?? false
        return hasModel || hasProvider
    }
}
