import Foundation
import AtlasCore

// MARK: - Conversation mid-thread occasion (WAVE-029)

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

    /// Pure-ish compile from route + hub presence (casca only).
    @MainActor
    static func facts(
        session: AtlasSession,
        threadId: ThreadID,
        title: String,
        workspaceKey: String? = nil
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

        // Live sessions matching this thread — face product words, not raw phaseTitle lead.
        let matchingLive = TurnPresence.shared.liveSessions.filter { $0.threadId == threadId }
            + session.remoteLiveSessions.filter { $0.threadId == threadId }
        if matchingLive.isEmpty {
            facts.append("sessoes_vivas_deste_fio: 0")
        } else {
            facts.append("sessoes_vivas_deste_fio: \(matchingLive.count)")
            for s in matchingLive.prefix(4) {
                let face = ConversationExecutionPhase.face(for: s)
                let product = ConversationExecutionPhase.primaryProduct(face)
                anchors.append("live · \(s.title) · \(product)")
                // phaseTitle as secondary detail only
                if !s.phaseTitle.isEmpty {
                    facts.append("live_detail · \(s.title) · \(s.phaseTitle)")
                }
            }
        }

        // Hub-wide live count without claiming other threads are this one.
        let hubLive = TurnPresence.shared.liveSessions.count
        if hubLive > matchingLive.count {
            facts.append("sessoes_vivas_hub_global: \(hubLive) (outras conversas podem estar vivas)")
        }

        absences.append("não invente grafo/Arena/Autônomos neste pack de conversa")
        absences.append("NL não autoriza tool write — stop/steer/fila só via CTA da face se publicados")

        // WAVE-084: mid-thread empty editorial (never Home catalog).
        let empty = ConversationEmptyJudgment.packFacts(
            prompt: invite,
            suggestions: emptySuggestions,
            isHomePartida: false
        )
        facts.append(contentsOf: empty.facts)
        absences.append(contentsOf: empty.absences)

        let surface: String
        if workspaceKey != nil {
            surface = "conversation.workspace"
        } else {
            surface = "conversation"
        }

        let ongoing = matchingLive.contains { $0.timing != .finished }
        let canDo: AgenticOccasionPack.CanDo = ongoing ? .faceCTALocal : .readChat

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
