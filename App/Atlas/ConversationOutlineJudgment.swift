import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive conversation outline face (WAVE-079).
enum ConversationOutlineFace: Equatable {
    case empty
    case turns(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .turns: return "turns"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem turnos carregados nesta thread"
        case .turns(let n):
            let noun = n == 1 ? "turno" : "turnos"
            return "\(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure conversation-outline grammar — face · spoken · pack.
enum ConversationOutlineJudgment {

    static func face(turnCount: Int) -> ConversationOutlineFace {
        turnCount <= 0 ? .empty : .turns(turnCount)
    }

    static func spokenSheetLabel(turnCount: Int) -> String {
        let face = face(turnCount: turnCount)
        switch face {
        case .empty:
            return "índice da conversa, \(face.spokenFace)"
        case .turns:
            return "índice da conversa, \(face.spokenFace)"
        }
    }

    static func spokenEmptySheet() -> String {
        "índice da conversa, sem turnos carregados nesta thread"
    }

    static func spokenRole(_ role: String) -> String {
        role == "user" ? "você" : "Atlas"
    }

    static func spokenSnippet(from text: String) -> String {
        let trimmed = AtlasMarkdown.plainText(text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "sem texto visível neste turno"
        }
        return String(trimmed.prefix(140))
    }

    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        "turno \(index), \(spokenRole(role)), \(snippet)"
    }

    static func packFacts(turnCount: Int) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(turnCount: turnCount)
        facts.append("outline_face: \(face.productWord)")
        switch face {
        case .empty:
            absences.append("índice sem turnos nesta thread")
            facts.append("outline_turns: 0")
        case .turns(let n):
            facts.append("outline_turns: \(n)")
        }
        return (facts, absences)
    }

    // MARK: Chrome spoken (IDLE · was ConversationViewA11y outline)

    static func spokenOutlineControl(turnCount: Int) -> String {
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static let outlineControlHint = "abre o índice editorial dos turnos desta conversa"
}
