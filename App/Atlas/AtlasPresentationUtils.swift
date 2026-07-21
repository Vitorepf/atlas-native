import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: presentation utility types fused

// MARK: - LoadPhase

enum LoadPhase: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}
// MARK: - StringNonEmpty

extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
// MARK: - AtlasAreaOf

extension AtlasArea {
    static func of(_ t: AtlasAiThread) -> AtlasArea {
        let surface = t.surface.lowercased()
        let mode = (t.metadata?["current_mode"]?.stringValue
            ?? t.metadata?["atlas_mode"]?.stringValue
            ?? t.metadata?["workflow_mode"]?.stringValue ?? "").lowercased()
        let domain = (t.metadata?["routing_domain"]?.stringValue ?? "").lowercased()
        if surface.contains("code") || domain.contains("eng") || domain.contains("prog") || mode.contains("program") {
            return .programacao
        }
        if mode.contains("auto") || mode.contains("loop") || (t.metadata?["awis_automation"]?.boolValue ?? false) {
            return .autonomos
        }
        return .operacional
    }
}
// MARK: - LiveSessionSnapshot

struct LiveSessionSnapshot: Identifiable, Equatable {
    let id: String            // traceId corrente (estável por execução)
    let threadId: ThreadID?   // para Route.thread; nil se conversa nova local
    let title: String
    let phaseTitle: String
    let timing: AtlasExecutionPresence.Timing
    let elapsedActiveMs: Int?
    let runningSince: Date?
    let pauseTimestamp: Date?
    /// 1ª observação local — só ordenação; nunca exibido como duração.
    let startedAt: Date
    let isRemote: Bool
}
// MARK: - AtlasUserMessage

func atlasUserMessage(forAPI error: Error) -> String? {
    guard let api = error as? AtlasApiError else { return nil }
    switch api.status {
    case 401, 403: return "A sessão do Atlas precisa ser reconectada."
    case 408, 429: return "O Atlas está ocupado. Este turno continua recuperável."
    case 500...599: return "O servidor Atlas está temporariamente indisponível."
    default: return api.message
    }
}

func atlasUserMessage(forStream error: Error) -> String? {
    guard error is AtlasInteractionStreamError else { return nil }
    return "A conexão com a execução caiu. O Atlas retomará este turno automaticamente."
}

func atlasUserMessage(forURL error: Error) -> String? {
    guard let urlError = error as? URLError else { return nil }
    switch urlError.code {
    case .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost,
         .cannotFindHost, .timedOut:
        return "A conexão caiu. O Atlas vai recuperar este turno quando a rede voltar."
    default:
        return "Não foi possível falar com o Atlas agora. Tente novamente."
    }
}

func atlasUserMessage(for error: Error) -> String {
    if let message = atlasUserMessage(forStream: error) { return message }
    if let message = atlasUserMessage(forURL: error) { return message }
    if let message = atlasUserMessage(forAPI: error) { return message }
    return "A execução foi interrompida. Tente novamente."
}
// MARK: - AtlasWorkspace

struct Workspace: Identifiable, Hashable {
    let id: String     // chave = nome de pasta minúsculo
    let name: String   // exibição
    let count: Int
}

enum AtlasArea: String, CaseIterable, Identifiable {
    case tudo, operacional, autonomos, programacao
    var id: String { rawValue }
}

extension AtlasArea {
    var label: String {
        labelDomain ?? "Tudo"
    }
}

extension AtlasArea {
    var labelDomain: String? {
        switch self {
        case .operacional: return "Operacional"
        case .autonomos: return "Autônomos"
        case .programacao: return "Programação"
        default: return nil
        }
    }
}
// MARK: - AtlasConventionalCommit

enum AtlasConventionalCommit {
    // ponytail: whitelist de tipos — evita falso-positivo de mensagem comum
    // com ":" ("nota: isso"). Cobre os tipos usados no Atlas + os padrão.
    private static let knownTypes: Set<String> = [
        "feat", "fix", "docs", "polish", "refactor", "chore",
        "test", "style", "perf", "build", "ci", "revert", "wip"
    ]

    /// `type` normalizado: minúsculo, PRIMEIRO segmento com escopo
    /// ("fix(ui)+polish(ui)" → "fix(ui)"); nil quando não-convencional.
    static func split(_ message: String) -> (type: String?, subject: String) {
        guard let sep = message.range(of: ": ") else { return (nil, message) }
        let head = String(message[..<sep.lowerBound])
        let subject = String(message[sep.upperBound...]).trimmingCharacters(in: .whitespaces)
        guard !subject.isEmpty, let type = conventionalType(head) else { return (nil, message) }
        return (type, subject)
    }

    private static func conventionalType(_ head: String) -> String? {
        guard !head.isEmpty, head.count <= 40, !head.contains(" ") else { return nil }
        // Primeiro segmento (antes de '+'): o tipo primário do commit.
        let segment = head.split(separator: "+", maxSplits: 1).first.map(String.init) ?? head
        let typeWord = segment.prefix { $0.isLetter }
        let remainder = segment[typeWord.endIndex...]
        // O resto do segmento tem de ser escopo/marca VÁLIDA ("(...)", "!" ou
        // vazio) — senão "fix-me"/"ci-cd" viraria tipo (falso-positivo).
        guard knownTypes.contains(typeWord.lowercased()), isValidScope(remainder) else { return nil }
        return typeWord.lowercased() + remainder
    }

    private static func isValidScope(_ raw: Substring) -> Bool {
        var s = raw
        if s.hasSuffix("!") { s = s.dropLast() }
        if s.isEmpty { return true }
        return s.first == "(" && s.last == ")"
    }
}
