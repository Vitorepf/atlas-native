import Foundation

// Signature who helper — peel de EditorialTurnA11y.

extension EditorialTurnA11y {
  static func signatureWho(provider: String?, model: String?) -> String? {
    if let model, !model.isEmpty, !model.hasSuffix("_default") { return model }
    if let provider, !provider.isEmpty {
      let word = providerWord(provider)
      return word.isEmpty ? provider : word
    }
    return nil
  }
}
