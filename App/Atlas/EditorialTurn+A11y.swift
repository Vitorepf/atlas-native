import Foundation

// Spoken labels — peel de EditorialTurnChrome (CICLO C residual honesty).
// Who → EditorialTurn+A11yWho.swift
// Feedback → EditorialTurn+A11yFeedback.swift

enum EditorialTurnA11y {
  static func spokenSignature(provider: String?, model: String?, elapsedMs: Int?) -> String {
    guard let who = signatureWho(provider: provider, model: model) else { return "" }
    if let ms = elapsedMs, ms > 0 { return "resposta de \(who), em \(humanDuration(ms))" }
    return "resposta de \(who)"
  }

  static func spokenUserMessage(_ text: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "mensagem sua, vazia" : "mensagem sua, \(trimmed)"
  }

  static let spokenFinalAnswerKicker = "resposta final"

  static let copyLongPressHint = "pressionar e segurar copia a resposta"
}
