import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive follow-up queue face (WAVE-051). FIFO order is sacred.
enum ComposerQueueFace: Equatable {
    case empty
    case single
    case multi(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .single: return "single"
        case .multi: return "multi"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "fila vazia"
        case .single:
            return "1 mensagem na fila"
        case .multi(let n):
            return "\(n) mensagens na fila"
        }
    }
}

// MARK: - Judgment

/// Pure composer queue grammar — face · head · labels · pack.
/// Does **not** re-order FIFO (model owns promote/remove).
enum ComposerQueueJudgment {

    static func face(from messages: [QueuedMessage]) -> ComposerQueueFace {
        switch messages.count {
        case 0: return .empty
        case 1: return .single
        default: return .multi(messages.count)
        }
    }

    /// FIFO head — first message sends when the turn ends.
    static func head(from messages: [QueuedMessage]) -> QueuedMessage? {
        messages.first
    }

    /// Operator-safe snippet; empty text → honest absence label.
    static func snippet(_ text: String, maxChars: Int = 28) -> String {
        let trimmed = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "(sem texto)" }
        if trimmed.count <= maxChars { return trimmed }
        return String(trimmed.prefix(maxChars - 1)) + "…"
    }

    static func chipLabel(from messages: [QueuedMessage]) -> String {
        let face = face(from: messages)
        guard let head = head(from: messages) else { return "Fila" }
        let snip = snippet(head.text)
        switch face {
        case .empty:
            return "Fila"
        case .single:
            return "Fila · \(snip)"
        case .multi(let n):
            return "Fila · \(n) · \(snip)"
        }
    }

    static func sheetTitle(from messages: [QueuedMessage]) -> String {
        switch face(from: messages) {
        case .empty: return "Fila"
        case .single: return "Fila · 1"
        case .multi(let n): return "Fila · \(n)"
        }
    }

    static func spokenChip(from messages: [QueuedMessage]) -> String {
        let face = face(from: messages)
        guard let head = head(from: messages) else { return face.spokenFace }
        let snip = snippet(head.text, maxChars: 48)
        switch face {
        case .empty:
            return face.spokenFace
        case .single:
            return "1 mensagem na fila durante a execução, próxima \(snip)"
        case .multi(let n):
            return "\(n) mensagens na fila durante a execução, próxima \(snip)"
        }
    }

    static func spokenSheet(from messages: [QueuedMessage]) -> String {
        let face = face(from: messages)
        guard let head = head(from: messages) else { return face.spokenFace }
        let snip = snippet(head.text, maxChars: 64)
        switch face {
        case .empty:
            return "fila vazia"
        case .single:
            return "fila, 1 mensagem, cabeça \(snip)"
        case .multi(let n):
            return "fila, \(n) mensagens, cabeça \(snip), a primeira envia quando o turno terminar"
        }
    }

    static func packFacts(from messages: [QueuedMessage]) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: messages)
        facts.append("queue_face: \(face.productWord)")
        facts.append("queue_count: \(messages.count)")
        guard let head = head(from: messages) else {
            absences.append("fila de follow-up vazia neste recorte")
            return (facts, absences)
        }
        facts.append("queue_head: \(snippet(head.text, maxChars: 80))")
        facts.append("queue_head_age_s: \(max(0, Int(Date().timeIntervalSince(head.createdAt))))")
        if messages.count > 1, let tail = messages.last {
            facts.append("queue_tail: \(snippet(tail.text, maxChars: 40))")
        }
        return (facts, absences)
    }
}
