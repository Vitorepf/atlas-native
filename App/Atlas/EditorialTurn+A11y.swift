import Foundation

// Spoken labels — peel de EditorialTurnChrome (CICLO C residual honesty).
// Who → EditorialTurn+A11yWho.swift

enum EditorialTurnA11y {
  static func spokenSignature(provider: String?, model: String?, elapsedMs: Int?) -> String {
    guard let who = signatureWho(provider: provider, model: model) else { return "" }
    if let ms = elapsedMs, ms > 0 { return "resposta de \(who), em \(humanDuration(ms))" }
    return "resposta de \(who)"
  }

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

  static func spokenUserMessage(_ text: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "mensagem sua, vazia" : "mensagem sua, \(trimmed)"
  }

  static let spokenFinalAnswerKicker = "resposta final"

  static let copyLongPressHint = "pressionar e segurar copia a resposta"
}
