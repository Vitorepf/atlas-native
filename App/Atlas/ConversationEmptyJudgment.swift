import Foundation

// MARK: - Types

/// Exclusive conversation empty-editorial face (WAVE-084).
/// Product words: silence | default_prompt | custom_prompt | suggestions(N).
enum ConversationEmptyFace: Equatable {
    case silence
    case defaultHome
    case customPrompt
    case suggestions(Int)

    var productWord: String {
        switch self {
        case .silence: return "silence"
        case .defaultHome: return "default_prompt"
        case .customPrompt: return "custom_prompt"
        case .suggestions(let n): return "suggestions(\(n))"
        }
    }

    var spokenFace: String {
        switch self {
        case .silence:
            return "partida em silêncio"
        case .defaultHome:
            return "partida home"
        case .customPrompt:
            return "convite customizado"
        case .suggestions(let n):
            let noun = n == 1 ? "sugestão" : "sugestões"
            return "\(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure empty-editorial grammar — face · prompt/chips resolve · spoken · pack.
/// WAVE-002 law: invite ≡ emptyPrompt ≡ suggestions ≡ turnFacts same occasion.
/// Never invents chips; Home catalog only when `isHomePartida`.
enum ConversationEmptyJudgment {

    static let defaultPromptQuote = "O que você quer pensar agora?"
    static let suggestionHint = "envia esta pergunta agora"

    // MARK: Resolve

    static func cleanPrompt(_ prompt: String?) -> String? {
        guard let raw = prompt?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return nil
        }
        return raw
    }

    static func cleanSuggestions(_ raw: [String]?) -> [String] {
        (raw ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Resolved chips: host list wins; Home catalog only on home partida when nil.
    static func resolvedSuggestions(
        suggestions: [String]?,
        isHomePartida: Bool,
        hasWorkspaces: Bool
    ) -> [String] {
        if let suggestions {
            return cleanSuggestions(suggestions)
        }
        if isHomePartida {
            return HomeAskContext.emptySuggestions(hasWorkspaces: hasWorkspaces)
        }
        return []
    }

    static func resolvedPrompt(_ prompt: String?) -> String {
        cleanPrompt(prompt) ?? defaultPromptQuote
    }

    // MARK: Face

    static func face(
        prompt: String?,
        suggestions: [String]?,
        isHomePartida: Bool,
        hasWorkspaces: Bool = false
    ) -> ConversationEmptyFace {
        let chips = resolvedSuggestions(
            suggestions: suggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
        let hasPrompt = cleanPrompt(prompt) != nil

        if isHomePartida {
            if chips.isEmpty && !hasPrompt { return .silence }
            return .defaultHome
        }
        if !chips.isEmpty { return .suggestions(chips.count) }
        if hasPrompt { return .customPrompt }
        return .silence
    }

    // MARK: Spoken (a11y)

    static func spokenPrompt(_ prompt: String?) -> String {
        let text = resolvedPrompt(prompt)
        return "conversa vazia, \(text.lowercased())"
    }

    static func spokenSuggestion(_ text: String, index: Int, total: Int) -> String {
        "sugestão \(index + 1) de \(total), \(text)"
    }

    static func spokenEmptyOrgan(
        prompt: String?,
        suggestions: [String]?,
        isHomePartida: Bool,
        hasWorkspaces: Bool = false
    ) -> String {
        let f = face(
            prompt: prompt,
            suggestions: suggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
        let chips = resolvedSuggestions(
            suggestions: suggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
        var parts = [f.spokenFace, spokenPrompt(prompt)]
        if !chips.isEmpty {
            parts.append("\(chips.count) chip\(chips.count == 1 ? "" : "s")")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Pack

    static func packFacts(
        prompt: String?,
        suggestions: [String]?,
        isHomePartida: Bool,
        hasWorkspaces: Bool = false
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let f = face(
            prompt: prompt,
            suggestions: suggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
        let chips = resolvedSuggestions(
            suggestions: suggestions,
            isHomePartida: isHomePartida,
            hasWorkspaces: hasWorkspaces
        )
        facts.append("empty_face: \(f.productWord)")
        facts.append("empty_suggestions_count: \(chips.count)")
        if isHomePartida {
            facts.append("empty_host: home_partida")
        } else {
            facts.append("empty_host: occasion")
        }
        if cleanPrompt(prompt) == nil {
            absences.append("empty_prompt não publicado — quote default local")
        }
        switch f {
        case .silence:
            absences.append("partida sem chips nem convite custom")
        case .defaultHome:
            facts.append("empty_catalog: home")
        case .customPrompt:
            absences.append("chips não publicados nesta ocasião")
        case .suggestions:
            break
        }
        return (facts, absences)
    }
}
