import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive shared ops-failure face (WAVE-080).
enum AtlasOpsFailureFace: Equatable {
    case network
    case domain
    case load

    var productWord: String {
        switch self {
        case .network: return "network"
        case .domain: return "domain"
        case .load: return "load"
        }
    }

    var spokenFace: String {
        switch self {
        case .network: return "falha de rede"
        case .domain: return "domínio não publicado"
        case .load: return "falha ao carregar"
        }
    }
}

// MARK: - Judgment

/// Pure ops-failure grammar — face · copy · retry · pack.
enum AtlasOpsFailureJudgment {

    static let domainHeadline = "A medição ainda não existe neste servidor"
    static let domainFootnote = "Nenhum índice, progresso ou resultado foi presumido."
    static let domainKicker = "Arena não publicada"
    static let retryLabelCentered = "Tentar de novo"
    static let retryLabelEditorial = "Tentar novamente"
    static let retrySpoken = "tentar de novo"

    static func face(mode: AtlasOpsFailureMode) -> AtlasOpsFailureFace {
        switch mode {
        case .network: return .network
        case .domainUnavailable: return .domain
        case .load: return .load
        }
    }

    static func headline(mode: AtlasOpsFailureMode) -> String {
        switch mode {
        case .network(let kind, let hasToken, _):
            return AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)
        case .domainUnavailable:
            return domainHeadline
        case .load(let headline, _):
            return headline
        }
    }

    static func footnote(mode: AtlasOpsFailureMode) -> String? {
        switch mode {
        case .network(let kind, let hasToken, _):
            return AtlasFailureCopy.hint(kind: kind, hasToken: hasToken)
        case .domainUnavailable:
            return domainFootnote
        case .load(_, let message):
            return message.isEmpty ? nil : message
        }
    }

    static func defaultKicker(mode: AtlasOpsFailureMode) -> String? {
        if case .domainUnavailable = mode { return domainKicker }
        return nil
    }

    static func defaultSymbol(mode: AtlasOpsFailureMode) -> String {
        switch mode {
        case .network: return "wifi.exclamationmark"
        case .domainUnavailable: return "shippingbox"
        case .load: return "exclamationmark.triangle"
        }
    }

    static func showsRetry(mode: AtlasOpsFailureMode) -> Bool {
        switch mode {
        case .network(_, let hasToken, _): return hasToken
        case .domainUnavailable, .load: return true
        }
    }

    static func spokenLabel(
        mode: AtlasOpsFailureMode,
        kicker: String?,
        spokenOverride: String?
    ) -> String {
        if let spokenOverride { return spokenOverride }
        var parts: [String] = []
        let resolvedKicker = kicker ?? defaultKicker(mode: mode)
        if let k = resolvedKicker { parts.append(k) }
        parts.append(headline(mode: mode))
        if let footnote = footnote(mode: mode) {
            parts.append(footnote.replacingOccurrences(of: "\n\n", with: ". "))
        }
        return parts.joined(separator: ". ")
    }

    static func packFacts(mode: AtlasOpsFailureMode) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(mode: mode)
        facts.append("ops_failure_face: \(face.productWord)")
        switch mode {
        case .network(_, let hasToken, let host):
            facts.append("ops_failure_host: \(host)")
            facts.append("ops_failure_has_token: \(hasToken)")
            absences.append("superfície offline ou sem token")
        case .domainUnavailable:
            absences.append("domínio não publicado — sem inventar scores")
        case .load(let headline, let message):
            facts.append("ops_failure_headline: \(headline)")
            if !message.isEmpty {
                facts.append("ops_failure_message: \(message)")
            }
            absences.append("load falhou com mensagem do host")
        }
        return (facts, absences)
    }
}
