import Foundation
import AtlasCore

// MARK: - Workspace / Search catalog judgment (WAVE-032)

/// Pure live-first ranking for thread catalogs — parity with LiveNow attention.
/// Prefer threadId identity; never invent live without signal.
enum WorkspaceThreadJudgment {

    // MARK: Running identity

    /// Thread ids with ongoing presence (local TurnPresence + remote hub).
    @MainActor
    static func liveThreadIDs(
        local: [LiveSessionSnapshot] = TurnPresence.shared.liveSessions,
        remote: [LiveSessionSnapshot] = []
    ) -> Set<String> {
        var ids = Set<String>()
        for session in local + remote {
            guard session.timing != .finished else { continue }
            if let tid = session.threadId?.rawValue, !tid.isEmpty {
                ids.insert(tid)
            }
        }
        return ids
    }

    /// Title fallback only when session has no threadId (local new conversation).
    @MainActor
    static func liveTitlesWithoutThreadID(
        local: [LiveSessionSnapshot] = TurnPresence.shared.liveSessions,
        remote: [LiveSessionSnapshot] = []
    ) -> Set<String> {
        var titles = Set<String>()
        for session in local + remote {
            guard session.timing != .finished else { continue }
            if session.threadId == nil {
                let t = session.title.trimmingCharacters(in: .whitespacesAndNewlines)
                if !t.isEmpty { titles.insert(t) }
            }
        }
        return titles
    }

    /// Honest running signal for a catalog row.
    @MainActor
    static func isRunning(
        threadID: String,
        title: String,
        liveIDs: Set<String>,
        liveTitlesFallback: Set<String>
    ) -> Bool {
        if liveIDs.contains(threadID) { return true }
        // Title fallback only when no threadId-bound live exists for this title collision path.
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && liveTitlesFallback.contains(trimmed)
    }

    @MainActor
    static func isRunning(
        thread: AtlasAiThread,
        remote: [LiveSessionSnapshot] = []
    ) -> Bool {
        let ids = liveThreadIDs(remote: remote)
        let titles = liveTitlesWithoutThreadID(remote: remote)
        return isRunning(threadID: thread.id, title: thread.title, liveIDs: ids, liveTitlesFallback: titles)
    }

    // MARK: Rank

    /// Live-first; stable secondary (input order). Empty live → unchanged order.
    @MainActor
    static func rank(
        _ threads: [AtlasAiThread],
        remote: [LiveSessionSnapshot] = []
    ) -> [AtlasAiThread] {
        let ids = liveThreadIDs(remote: remote)
        let titles = liveTitlesWithoutThreadID(remote: remote)
        guard !ids.isEmpty || !titles.isEmpty else { return threads }

        return threads.enumerated().sorted { lhs, rhs in
            let lLive = isRunning(
                threadID: lhs.element.id,
                title: lhs.element.title,
                liveIDs: ids,
                liveTitlesFallback: titles
            )
            let rLive = isRunning(
                threadID: rhs.element.id,
                title: rhs.element.title,
                liveIDs: ids,
                liveTitlesFallback: titles
            )
            if lLive != rLive { return lLive && !rLive }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    // MARK: Pack shell (WAVE-185)

    /// Workspace catalog shell — key · thread count · path honesty.
    static func packShellFacts(
        workspaceKey: String,
        displayName: String,
        threadCount: Int,
        fullPath: String?
    ) -> (facts: [String], absences: [String], anchors: [String]) {
        var facts: [String] = [
            "workspace_key: \(workspaceKey)",
            "workspace_thread_count: \(threadCount)",
        ]
        var absences: [String] = []
        let anchors: [String] = ["workspace: \(displayName)"]

        if let fullPath, !fullPath.isEmpty {
            facts.append("workspace_path: \(fullPath)")
        } else {
            absences.append("caminho completo do workspace não listado nas threads")
        }
        if threadCount == 0 {
            absences.append("ainda não há conversas neste workspace")
        }
        absences.append("não invente grafo/Arena/frota; pack é só deste workspace")
        return (facts, absences, anchors)
    }

    // MARK: Pack live scoped

    /// Live subjects scoped to a workspace path/key when published.
    @MainActor
    static func liveInWorkspaceFacts(
        workspaceKey: String?,
        sessionThreads: [AtlasAiThread],
        remote: [LiveSessionSnapshot] = []
    ) -> (facts: [String], absences: [String], subjects: [String]) {
        let ranked = rank(sessionThreads, remote: remote)
        let live = ranked.filter { isRunning(thread: $0, remote: remote) }
        var facts: [String] = []
        var absences: [String] = []
        if live.isEmpty {
            facts.append("live_neste_workspace: 0")
            absences.append("nenhuma sessão viva casada por threadId neste catálogo")
        } else {
            facts.append("live_neste_workspace: \(live.count)")
            for t in live.prefix(5) {
                facts.append("live_thread: \(t.title)")
            }
        }
        if workspaceKey != nil {
            facts.append("catalogo: workspace_scoped")
        }
        return (facts, absences, live.prefix(5).map(\.title))
    }

    // MARK: Catalog chrome spoken (IDLE · was RootChromeRowA11y)

    static let profileLabel = "perfil do operador"
    static let profileHint = "abre seu perfil e o estado da sessão"

    static func workspaceSpoken(
        name: String,
        count: Int?,
        detail: String?,
        badge: Bool
    ) -> String {
        var parts = [name]
        if let count {
            parts.append(count == 0 ? "nenhuma conversa" : "\(count) conversa\(count == 1 ? "" : "s")")
        }
        if let detail, !detail.isEmpty {
            parts.append(detail)
        }
        if badge {
            parts.append("atenção necessária")
        }
        return parts.joined(separator: ", ")
    }

    static func threadSpoken(
        title: String,
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> String {
        var parts = [title]
        if isRunning {
            parts.append("Atlas executando")
        } else if messageCount == 0 {
            parts.append("nenhuma mensagem")
        } else {
            parts.append("\(messageCount) mensagem\(messageCount == 1 ? "" : "ns")")
        }
        if isNew && !isRunning {
            parts.append("novo desde a última visita")
        }
        if hasWorkspace {
            parts.append("com workspace")
        }
        return parts.joined(separator: ", ")
    }

    static func threadHint(isRunning: Bool) -> String {
        isRunning ? "Atlas executando nesta conversa" : "abre a conversa"
    }
}
