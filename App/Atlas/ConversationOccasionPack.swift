import Foundation
import AtlasCore

// MARK: - Conversation mid-thread occasion (WAVE-029)
// WAVE-171 density peel — host (slice + shell); Live/Organs peels.

/// Compiles turnFacts for an **open thread** — never Home partida.
/// Surface purity: `conversation` or `conversation.workspace`.
enum ConversationOccasionPack {

    static let invite = "continue nesta conversa"

    static var emptySuggestions: [String] {
        [
            "O que mudou neste fio?",
            "Resume o estado da execução",
            "O que preciso julgar agora?"
        ]
    }

    /// Live mid-thread slice from ConversationModel (WAVE-106).
    /// Never invent: only published bubble/queue/agents.
    /// Not Equatable: handoff DTO is Codable-only (no Core change).
    struct PublishedSlice {
        var presenceBubble: ChatBubble?
        var queued: [QueuedMessage]
        var agents: [ExecAgent]
        /// WAVE-160: last steer receipt from model (nil → absence).
        var lastSteerReceipt: AtlasInteractionSteerResponse? = nil
        /// WAVE-161: surface handoff receipt (nil → absence).
        var latestSurfaceHandoff: AtlasAiSurfaceHandoff? = nil
        /// WAVE-163: change review for presence trace (nil → absence).
        var changeReview: AtlasTraceChangeReview? = nil
        /// WAVE-163: whether review load finished for this trace.
        var changeReviewLoadFinished: Bool = false
        /// WAVE-164: composer draft strip + effort + cache seal.
        var drafts: [LocalDraft] = []
        var uploadPercent: Double? = nil
        var effort: AtlasComputeEffort = .auto
        var cacheCapturedAt: Date? = nil
        var artifacts: [AtlasTraceArtifacts.Item] = []
        /// WAVE-170: full artifacts bag when published for ArtifactJudgment.
        var artifactsBag: AtlasTraceArtifacts? = nil
        /// WAVE-166: outline turn count + toolbar chrome.
        var turnCount: Int = 0
        var toolbarMode: String = ""
        var toolbarWorkspaceName: String? = nil
        /// WAVE-168: messages load fail + presence + workspace catalog count.
        var hasLoadError: Bool = false
        var workspaceCatalogCount: Int = 0

        static let unbound = PublishedSlice(
            presenceBubble: nil,
            queued: [],
            agents: []
        )

        var hasModel: Bool { true }
    }

    /// Pure-ish compile from route + hub presence (casca only).
    /// `published` hydrates queue/plan/lanes/decision from the live model when bound.
    @MainActor
    static func facts(
        session: AtlasSession,
        threadId: ThreadID,
        title: String,
        workspaceKey: String? = nil,
        published: PublishedSlice? = nil
    ) -> String {
        var anchors: [String] = []
        var facts: [String] = []
        var absences: [String] = []

        let subjectTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let subject = subjectTitle.isEmpty ? "conversa \(threadId.rawValue.prefix(8))" : subjectTitle

        facts.append("thread_id: \(threadId.rawValue)")
        facts.append("thread_title: \(subject)")

        if let workspaceKey {
            facts.append("workspace_key: \(workspaceKey)")
            if let name = session.workspaces.first(where: { $0.id == workspaceKey })?.name {
                facts.append("workspace_name: \(name)")
            }
        } else if let thread = session.threads.first(where: { $0.id == threadId.rawValue }) {
            if let ws = thread.workspace, !ws.isEmpty {
                facts.append("workspace_path: \(ws)")
            } else {
                absences.append("workspace da thread não publicado no catálogo local")
            }
        } else {
            absences.append("thread ainda não listada no catálogo local da sessão")
        }

        let matchingLive = appendLiveSessionFacts(
            session: session,
            threadId: threadId,
            into: &facts,
            anchors: &anchors,
            absences: &absences
        )

        absences.append("não invente grafo/Arena/Autônomos neste pack de conversa")

        // WAVE-084: mid-thread empty editorial (never Home catalog).
        let empty = ConversationEmptyJudgment.packFacts(
            prompt: invite,
            suggestions: emptySuggestions,
            isHomePartida: false
        )
        facts.append(contentsOf: empty.facts)
        absences.append(contentsOf: empty.absences)

        let canDo = appendLiveOrgans(
            published: published,
            matchingLive: matchingLive,
            into: &facts,
            absences: &absences
        )

        appendSteerHandoffReviewOrgans(
            published: published,
            matchingLive: matchingLive,
            into: &facts,
            absences: &absences
        )
        appendComposerEvidenceOrgans(
            published: published,
            matchingLive: matchingLive,
            into: &facts,
            absences: &absences
        )

        let surface: String
        if workspaceKey != nil {
            surface = "conversation.workspace"
        } else {
            surface = "conversation"
        }

        return AgenticOccasionPack(
            surface: surface,
            subject: subject,
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: canDo
        ).render()
    }

    /// Shared live-anchor line for Home/Workspace packs (face product words).
    static func liveAnchorLine(_ session: LiveSessionSnapshot) -> String {
        let face = ConversationExecutionPhase.face(for: session)
        let product = ConversationExecutionPhase.primaryProduct(face)
        return "live · \(session.title) · \(product)"
    }
}
