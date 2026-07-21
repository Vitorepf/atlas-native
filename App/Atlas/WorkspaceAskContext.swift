import Foundation
import AtlasCore

/// Pack de ocasião do Workspace — WAVE-020 grammar.
enum WorkspaceAskContext {
    static func invite(workspaceName: String) -> String {
        "Escreva sobre \(workspaceName)"
    }

    static func emptySuggestions(workspaceName: String, threadCount: Int) -> [String] {
        if threadCount > 0 {
            return [
                "O que está vivo em \(workspaceName)?",
                "Resume as conversas recentes deste workspace",
                "O que preciso julgar aqui?"
            ]
        }
        return [
            "Começa a primeira conversa em \(workspaceName)",
            "O que este workspace precisa agora?",
            "Como organizar o trabalho aqui?"
        ]
    }

    @MainActor
    static func facts(session: AtlasSession, workspaceKey: String) -> String {
        let name = session.workspaces.first(where: { $0.id == workspaceKey })?.name ?? workspaceKey
        let threads = session.threads(inWorkspace: workspaceKey)
        var anchors: [String] = []
        var facts: [String] = [
            "workspace_key: \(workspaceKey)",
            "conversas_neste_workspace: \(threads.count)",
        ]
        var absences: [String] = []

        if let full = session.workspaceFullPath(forKey: workspaceKey) {
            facts.append("caminho: \(full)")
        } else {
            absences.append("caminho completo do workspace não listado nas threads")
        }

        for t in threads.prefix(6) {
            let shown = t.title.trimmingCharacters(in: .whitespacesAndNewlines)
            anchors.append(shown.isEmpty ? "thread sem título" : shown)
        }
        if threads.isEmpty {
            absences.append("ainda não há conversas neste workspace")
        }

        let live = TurnPresence.shared.liveSessions
        if live.isEmpty {
            facts.append("sessoes_vivas_hub: 0")
        } else {
            facts.append("sessoes_vivas_hub_global: \(live.count) (não assumir que são deste workspace)")
            for s in live.prefix(3) {
                // WAVE-029: face product words on hub live lines.
                facts.append("hub_live · \(ConversationOccasionPack.liveAnchorLine(s))")
            }
        }

        // WAVE-032: live slice of **this** workspace catalog (threadId match).
        let scoped = WorkspaceThreadJudgment.liveInWorkspaceFacts(
            workspaceKey: workspaceKey,
            sessionThreads: threads,
            remote: session.remoteLiveSessions
        )
        facts.append(contentsOf: scoped.facts)
        absences.append(contentsOf: scoped.absences)
        for subject in scoped.subjects {
            anchors.append("live · \(subject)")
        }

        absences.append("não invente grafo/Arena/frota; pack é só deste workspace")

        // WAVE-162: workspace screen face organ (loading/offline/empty/list).
        let showsLoading = (session.phase == .loading || session.phase == .idle) && threads.isEmpty
        let showsOffline = {
            if case .failed = session.phase { return threads.isEmpty }
            return false
        }()
        let screenPack = WorkspaceScreenJudgment.packFacts(
            title: name,
            showsLoadingShell: showsLoading,
            showsNetworkFailure: showsOffline,
            threadCount: threads.count,
            areaLabel: "todas",
            freeOnly: false
        )
        facts.append(contentsOf: screenPack.facts)
        absences.append(contentsOf: screenPack.absences)

        // WAVE-166: empty editorial organ when catalog silence.
        if threads.isEmpty {
            let emptyPack = WorkspaceEmptyJudgment.packFacts(
                area: .tudo,
                freeOnly: false,
                screenTitle: name
            )
            facts.append(contentsOf: emptyPack.facts)
            absences.append(contentsOf: emptyPack.absences)
        }

        // WAVE-166: ops failure organ when load failed with empty list.
        if showsOffline {
            let failPack = AtlasOpsFailureJudgment.packFacts(
                mode: .network(kind: session.failureKind ?? .offline, hasToken: session.hasToken, host: session.host)
            )
            facts.append(contentsOf: failPack.facts)
            absences.append(contentsOf: failPack.absences)
        }

        // WAVE-158: can_do matrix — scoped live never invents stop on workspace pack.
        let scopedLiveCount = WorkspaceThreadJudgment.rank(threads, remote: session.remoteLiveSessions)
            .filter { WorkspaceThreadJudgment.isRunning(thread: $0, remote: session.remoteLiveSessions) }
            .count
        let partida = PartidaCanDoJudgment.workspace(scopedLiveCount: scopedLiveCount)
        absences.append(contentsOf: partida.absences)

        return AgenticOccasionPack(
            surface: "workspace",
            subject: name,
            anchors: anchors,
            facts: facts,
            absences: absences,
            canDo: partida.canDo
        ).render()
    }

    /// Nova conversa livre (sem workspace) — distinta da Home partida.
    static let freeInvite = "Escreva livremente"
}
