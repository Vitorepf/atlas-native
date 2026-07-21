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
