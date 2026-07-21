import Foundation
import AtlasCore

// MARK: - Judgment

/// Pure mid-thread shell identity (WAVE-185) — thread · title · workspace binding.
/// Never invents workspace path or catalog membership.
enum ConversationThreadShellJudgment {

    /// Subject line for AgenticOccasionPack (empty title → honest prefix).
    static func subject(
        threadId: ThreadID,
        title: String
    ) -> String {
        let subjectTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return subjectTitle.isEmpty
            ? "conversa \(threadId.rawValue.prefix(8))"
            : subjectTitle
    }

    /// Pack shell facts for an open conversation route.
    @MainActor
    static func packFacts(
        session: AtlasSession,
        threadId: ThreadID,
        title: String,
        workspaceKey: String?
    ) -> (facts: [String], absences: [String], subject: String) {
        var facts: [String] = []
        var absences: [String] = []
        let subject = subject(threadId: threadId, title: title)

        facts.append("thread_id: \(threadId.rawValue)")
        facts.append("thread_title: \(subject)")

        if let workspaceKey {
            facts.append("workspace_key: \(workspaceKey)")
            if let name = session.workspaces.first(where: { $0.id == workspaceKey })?.name {
                facts.append("workspace_name: \(name)")
            } else {
                absences.append("nome do workspace não listado no catálogo da sessão")
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

        absences.append("não invente grafo/Arena/Autônomos neste pack de conversa")
        return (facts, absences, subject)
    }
}
