import Foundation

// Feedback spoken — peel de EditorialTurn+A11y.
// Base → EditorialTurn+A11yFeedback+Base.swift

extension EditorialTurnA11y {
  static func spokenFeedbackLabel(kind: FeedbackKind, active: Bool) -> String {
    let base = spokenFeedbackBase(kind: kind)
    return active ? "\(base), selecionado" : base
  }

  static func spokenFeedbackHint() -> String {
    "envia feedback ao roteamento do Atlas para este turno"
  }
}
