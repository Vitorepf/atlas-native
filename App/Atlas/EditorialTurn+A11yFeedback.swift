import Foundation

// Feedback spoken — peel de EditorialTurn+A11y.

extension EditorialTurnA11y {
  static func spokenFeedbackLabel(kind: FeedbackKind, active: Bool) -> String {
    let base: String
    switch kind {
    case .util: base = "marcar resposta como útil"
    case .contexto: base = "marcar contexto errado"
    case .longo: base = "marcar resposta longa demais"
    case .fraco: base = "marcar resposta fraca"
    }
    return active ? "\(base), selecionado" : base
  }

  static func spokenFeedbackHint() -> String {
    "envia feedback ao roteamento do Atlas para este turno"
  }
}
