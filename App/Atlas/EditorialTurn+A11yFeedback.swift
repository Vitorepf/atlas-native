import Foundation

// Cycle 037 fuse → EditorialTurn+A11yFeedback.swift

extension EditorialTurnA11y {
  static func spokenFeedbackBase(kind: FeedbackKind) -> String {
    switch kind {
    case .util: return "marcar resposta como útil"
    case .contexto: return "marcar contexto errado"
    case .longo: return "marcar resposta longa demais"
    case .fraco: return "marcar resposta fraca"
    }
  }
}

extension EditorialTurnA11y {
  static func spokenFeedbackLabel(kind: FeedbackKind, active: Bool) -> String {
    let base = spokenFeedbackBase(kind: kind)
    return active ? "\(base), selecionado" : base
  }

  static func spokenFeedbackHint() -> String {
    "envia feedback ao roteamento do Atlas para este turno"
  }
}
