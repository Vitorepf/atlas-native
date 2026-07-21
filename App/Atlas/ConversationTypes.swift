import AtlasCore
import Foundation

// IDLE-COMPRESS fused

// --- ConversationTypes+ChatBubble+Activity.swift ---
extension ChatBubble {
    var currentActivity: AtlasAgentActivity? { atlasCurrentAgentActivity(from: activities) }
}

// --- ConversationTypes+ChatBubble+LiveSurface.swift ---
extension ChatBubble {
    var hasLiveExecutionSurface: Bool {
        showsReconnectSurface
            || !activities.isEmpty
            || !agents.isEmpty
            || decideStrategy != nil
    }
}

// --- ConversationTypes+ChatBubble+Presence.swift ---
extension ChatBubble {
    var executionPresence: AtlasExecutionPresence? {
        AtlasExecutionPresence(
            isExecuting: streaming,
            presentationState: executionPresentationState,
            currentActivity: currentActivity
        )
    }
}

// --- ConversationTypes+ExecAgent.swift ---
struct ExecAgent: Equatable, Identifiable {
    let id: String
    let agent: String?     // orquestrador / atlas / …
    let provider: String?  // hermes_cli / claude_cli / …
    let model: String?     // claude-sonnet-4-6 / qwen3.6-27b / …
    let status: String     // queued / processing / succeeded / failed / …
}

// --- ConversationTypes+Feedback+ActiveAction.swift ---
extension FeedbackKind {
    var activeAction: String {
        switch self {
        case .util: return "useful"
        case .contexto: return "wrong_context"
        case .longo: return "too_long"
        case .fraco: return "weak"
        }
    }
}

// --- ConversationTypes+Feedback+Label.swift ---
extension FeedbackKind {
    var label: String {
        switch self {
        case .util: return "útil"
        case .contexto: return "contexto"
        case .longo: return "longo"
        case .fraco: return "fraco"
        }
    }
}

// --- ConversationTypes+Feedback+Payload.swift ---
extension FeedbackKind {
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

// --- ConversationTypes+Feedback.swift ---
enum FeedbackKind: String, CaseIterable, Identifiable {
    case util, contexto, longo, fraco
    var id: String { rawValue }
}

// --- ConversationTypes+LocalDraft.swift ---
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

// --- ConversationTypes.swift ---
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
    var startedAt: Date? = nil
    var elapsedMs: Int? = nil
    var agents: [ExecAgent] = []
    var decideStage: String? = nil
    var decideStrategy: String? = nil
    var activities: [AtlasAgentActivity] = []
    var reconnectNotice: String? = nil
    var decisionSummary: AtlasDecisionSummary? = nil
    var qualitySummary: AtlasQualitySummary? = nil
    var executionPlan: AtlasExecutionPlan? = nil
    var diffStats: AtlasTraceGovernance.DiffStats? = nil
    var planRevisions: [AtlasTraceGovernance.PlanRevision] = []
    var executionProgress: AtlasExecutionPlan.Progress? = nil
    var executionPresentationState: AtlasExecutionPresentationState? = nil
    var executionChoiceJobId: JobID? = nil
    var retryableJobId: JobID? = nil
}
