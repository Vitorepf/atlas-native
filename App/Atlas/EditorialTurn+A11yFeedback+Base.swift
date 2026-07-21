import Foundation

// Feedback base labels — peel de EditorialTurn+A11yFeedback.

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
