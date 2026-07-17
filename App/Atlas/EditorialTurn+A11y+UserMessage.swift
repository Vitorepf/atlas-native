import Foundation

// spokenUserMessage — peel de EditorialTurn+A11y.

extension EditorialTurnA11y {
  static func spokenUserMessage(_ text: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "mensagem sua, vazia" : "mensagem sua, \(trimmed)"
  }

  static let spokenFinalAnswerKicker = "resposta final"

  static let copyLongPressHint = "pressionar e segurar copia a resposta"
}
