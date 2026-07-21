import Foundation
import AtlasCore

struct ChatBubble: Identifiable, Equatable {
    let id: String
    let role: String
    var text: String
    var streaming: Bool = false
    var traceId: TraceID? = nil
    var occurredAt: String? = nil
    var provider: String? = nil
    var model: String? = nil
    var feedbackAction: String? = nil
    // Execução ao vivo (a orquestra)
    var startedAt: Date? = nil
    var elapsedMs: Int? = nil
    var agents: [ExecAgent] = []
    var decideStage: String? = nil
    var decideStrategy: String? = nil
    var activities: [AtlasAgentActivity] = []
    /// Aviso público do stream resumível. Só aparece quando o InteractionRun
    /// expõe uma tentativa real de reconexão; a View não estima rede.
    var reconnectNotice: String? = nil
    var decisionSummary: AtlasDecisionSummary? = nil
    var qualitySummary: AtlasQualitySummary? = nil
    /// Plano real criado pelo Terminal/CLI; a casca só recebe os dados já
    /// saneados pelo Core, nunca metadata/prompt bruto.
    var executionPlan: AtlasExecutionPlan? = nil
    /// C18: shortstat real do workspace. `nil` = sem workspace / sem medida —
    /// a casca NÃO inventa +0 −0.
    var diffStats: AtlasTraceGovernance.DiffStats? = nil
    /// C19: planos arquivados em replanejamento. Vazio = nunca replanejou.
    var planRevisions: [AtlasTraceGovernance.PlanRevision] = []
    /// Posição do último checkpoint público observado no ledger. `nil` é o
    /// estado honesto para traces legados ou sem checkpoint, não zero falso.
    var executionProgress: AtlasExecutionPlan.Progress? = nil
    /// Estado editorial público e acionável, recebido do ledger/snapshot. A
    /// View nunca deduz atenção, recovery ou falha a partir de texto do modelo.
    var executionPresentationState: AtlasExecutionPresentationState? = nil
    /// Job real que aceitaria uma ação pública. `nil` fora de atenção necessária;
    /// a casca usa este id apenas através de `resolveExecutionChoice`.
    var executionChoiceJobId: JobID? = nil
    /// C17: job real que FALHOU e aceita retry. `nil` quando não há job em
    /// estado falho; a casca só oferece "Retomar" com ele.
    var retryableJobId: JobID? = nil
}

extension ChatBubble {
    var currentActivity: AtlasAgentActivity? { atlasCurrentAgentActivity(from: activities) }

    /// Só renderiza ribbon quando há dado real.
    var hasLiveExecutionSurface: Bool {
        showsReconnectSurface
            || !activities.isEmpty
            || !agents.isEmpty
            || decideStrategy != nil
    }

    /// Dado único para presença do iOS: título de fase e regra de timer vêm do
    /// Core tipado, nunca de uma animação ou de texto do provider.
    var executionPresence: AtlasExecutionPresence? {
        AtlasExecutionPresence(
            isExecuting: streaming,
            presentationState: executionPresentationState,
            currentActivity: currentActivity
        )
    }
}

struct ExecAgent: Equatable, Identifiable {
    let id: String
    let agent: String?     // orquestrador / atlas / …
    let provider: String?  // hermes_cli / claude_cli / …
    let model: String?     // claude-sonnet-4-6 / qwen3.6-27b / …
    let status: String     // queued / processing / succeeded / failed / …
}

/// Anexo local (pré-envio). O ÚNICO contrato de UI de anexos: a strip do
/// composer renderiza isto e nada mais.
struct LocalDraft: Identifiable, Equatable {
    enum State: Equatable { case pronto, subindo, falhou(String) }
    let id: String
    let fileName: String
    let mimeType: String
    let kind: AtlasAttachmentKind
    let bytes: Int
    let preview: Data?     // pequena o bastante pra UIImage(data:) direto
    var state: State = .pronto
}


/// Fase de carregamento compartilhada pelos models de leitura da casca.
/// ConversationModel fica fora — estado mais rico, não force-fit.
enum LoadPhase: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

extension String {
    /// Trim; nil se vazio.
    var nonEmpty: String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
// Cycle 044 fuse → AtlasUserMessage.swift

/// Mensagens de erro amigáveis partilhadas entre models da casca.

func atlasUserMessage(for error: Error) -> String {
    if let message = atlasUserMessage(forStream: error) { return message }
    if let message = atlasUserMessage(forURL: error) { return message }
    if let message = atlasUserMessage(forAPI: error) { return message }
    return "A execução foi interrompida. Tente novamente."
}

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


/// Feedback editorial do operador — peel de ConversationTypes.
enum FeedbackKind: String, CaseIterable, Identifiable {
    case util, contexto, longo, fraco
    var id: String { rawValue }

    var label: String {
        switch self {
        case .util: return "útil"
        case .contexto: return "contexto"
        case .longo: return "longo"
        case .fraco: return "fraco"
        }
    }

    var activeAction: String {
        switch self {
        case .util: return "useful"
        case .contexto: return "wrong_context"
        case .longo: return "too_long"
        case .fraco: return "weak"
        }
    }

    var payload: FeedbackAiInteractionInput {
        switch self {
        case .util:
            return .init(feedbackScore: 5, feedbackAction: "useful")
        case .contexto:
            return .init(feedbackScore: 1, feedbackAction: "wrong_context")
        case .longo:
            return .init(feedbackScore: 2, feedbackComment: "[too_long]")
        case .fraco:
            return .init(feedbackScore: 1, feedbackComment: "[weak]")
        }
    }
}
// ConversationModel+Continuity untouched (Core model territory).

func atlasRelativeAgePT(since date: Date, now: Date = Date()) -> String {
    let seconds = max(0, Int(now.timeIntervalSince(date)))
    if seconds < 60 { return "menos de 1 min" }

    let minutes = seconds / 60
    if minutes < 60 { return "\(minutes) min" }

    let hours = minutes / 60
    if hours < 24 { return "\(hours)h" }

    let days = hours / 24
    return days == 1 ? "1 dia" : "\(days) dias"
}

func atlasHandoffStatusEditorial(_ status: String) -> String {
    switch status {
    case "ready": return "pronto"
    case "pending": return "enviando"
    default: return status
    }
}

func atlasSurfaceLabel(_ raw: String) -> String {
    switch raw {
    case "atlas_mobile": return "iPhone"
    case "atlas_desktop": return "Mac"
    case "atlas_terminal": return "Terminal"
    default: return raw
    }
}

func editorialThreadPrefix(_ threadId: String) -> String {
    let trimmed = threadId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.count > 12 else { return trimmed }
    return String(trimmed.prefix(12)) + "…"
}


// Cycle 043 fuse → AtlasFailureCopy.swift

/// Copy editorial por `AtlasNetworkFailureKind` — home e conversa compartilham
/// a mesma voz (offline × timeout × recusada × …). Presentation-only.
enum AtlasFailureCopy {
    static func headline(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Falta a chave do Atlas." }
        guard let kind else { return "O servidor está fora de alcance." }
        return networkHeadline(kind: kind) ?? authServerHeadline(kind: kind)
    }
}

extension AtlasFailureCopy {
    static func authServerHint(kind: AtlasNetworkFailureKind) -> String {
        switch kind {
        case .unauthorized: return "O ATLAS_TOKEN mudou no servidor. Atualize o Secrets.xcconfig e reinstale."
        case .maintenance: return "O servidor pediu uma pausa via Retry-After. O app aguarda você tentar de novo quando a janela terminar."
        case .serverUnavailable: return "O servidor respondeu, mas está fora do ar. Veja os logs no Mac."
        default: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
    }
}

extension AtlasFailureCopy {
    static func networkOfflineHint(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Sem rede no iPhone. O Atlas volta sozinho assim que a conexão voltar."
        case .timedOut: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func networkHint(kind: AtlasNetworkFailureKind) -> String? {
        if let offline = networkOfflineHint(kind: kind) { return offline }
        switch kind {
        case .connectionRefused: return "No Mac, suba o servidor: o container atlas-backend parou."
        case .connectionLost: return "Instabilidade momentânea — tentar de novo costuma resolver."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func hint(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Configure o token no Mac e reinstale — nada foi perdido." }
        guard let kind else {
            return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
        return networkHint(kind: kind) ?? authServerHint(kind: kind)
    }
}

extension AtlasFailureCopy {
    static func authServerHeadline(kind: AtlasNetworkFailureKind) -> String {
        switch kind {
        case .unauthorized: return "A chave do Atlas foi recusada."
        case .maintenance: return "Atlas está em manutenção."
        case .serverUnavailable: return "O servidor está indisponível."
        default: return "O servidor está fora de alcance."
        }
    }
}

extension AtlasFailureCopy {
    static func networkOfflineHeadline(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Você está sem internet."
        case .timedOut: return "O Mac não respondeu a tempo."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func networkHeadline(kind: AtlasNetworkFailureKind) -> String? {
        if let offline = networkOfflineHeadline(kind: kind) { return offline }
        switch kind {
        case .connectionRefused: return "O servidor do Atlas não está de pé."
        case .connectionLost: return "A conexão caiu no meio do caminho."
        default: return nil
        }
    }
}
