import Foundation

extension AtlasClient {
    // MARK: - Atlas Código (read-only graph / heal / week)

    /// C22 · Read-only Git topology for Atlas Código. The server owns Git
    /// inspection; the native client only decodes the versioned projection.
    public func getCodeGraph(
        repo: String,
        before: String? = nil,
        limit: Int = 200
    ) async throws -> AtlasCodeGraphResponse {
        let query = atlasQueryString([
            ("repo", .string(repo)),
            ("before", before.map { .string($0) }),
            ("limit", .int(limit)),
        ])
        return try await get("\(AtlasRoute.codeGraph)\(query)")
    }

    /// C23 · Read-only identity and ledger-backed provenance for one commit.
    public func getCodeProvenance(hash: String, repo: String? = nil) async throws -> AtlasCodeProvenance {
        let query = atlasQueryString([
            ("repo", repo.map { .string($0) }),
        ])
        return try await get("\(AtlasRoute.codeProvenance(hash))\(query)")
    }

    /// C24 · Read-only five-rule governance scan for the selected repository.
    public func getCodeViolations(repo: String) async throws -> AtlasCodeViolationsResponse {
        try await get("\(AtlasRoute.codeViolations)\(atlasQueryString([("repo", .string(repo))]))")
    }

    /// M3 radar · o workspace real: recentes + pastas de produto. Read-only.
    public func getCodeWorkspace() async throws -> AtlasCodeWorkspaceResponse {
        try await get(AtlasRoute.codeRepos)
    }

    /// H6 · a pílula pergunta ao grafo. Read-only: perguntar nunca muta o repo.
    ///
    /// O fuso vai do aparelho, não do servidor: quem sabe que dia é "hoje" para
    /// o operador é o telefone no bolso dele. Sem isso o servidor responde em
    /// UTC e "hoje" começa às 21h de ontem.
    /// H6 · a leitura determinística do git.
    ///
    /// `mode` é o verbo, e por isso é explícito: `facts` LÊ (é o que roda a cada
    /// turno do card, alimentando o agente); `answer` pode AGIR — "revise os
    /// commits de hoje" nele manda a frota trabalhar. Um coletor de fato que
    /// despacha 12 agentes é a definição de efeito colateral, então quem chama
    /// diz o que quer, e o servidor recusa modo que não conhece.
    public func askCode(
        repo: String,
        question: String,
        mode: AtlasCodeAskMode = .answer
    ) async throws -> AtlasCodeAskResponse {
        struct Body: Encodable {
            let repo: String
            let question: String
            let timezone: String
            let mode: String
        }
        return try await post(
            AtlasRoute.codeAsk,
            body: Body(
                repo: repo,
                question: question,
                timezone: TimeZone.current.identifier,
                mode: mode.rawValue
            ),
            timeout: 25
        )
    }

    /// M5 mirror · what would leave the Mac, and what the scan found. Read-only.
    public func getCodeMirror(repo: String) async throws -> AtlasCodeMirrorResponse {
        try await get("\(AtlasRoute.codeMirror)\(atlasQueryString([("repo", .string(repo))]))")
    }

    /// C25 · Observe/heal tick. Observe remains the default and does not mutate Git.
    public func getCodeHealTick(repo: String, mode: String = "observe") async throws -> AtlasCodeHealResponse {
        let query = atlasQueryString([
            ("repo", .string(repo)),
            ("mode", .string(mode)),
        ])
        return try await get("\(AtlasRoute.codeHealsTick)\(query)")
    }

    /// C25 · Reverses a recorded heal step; the server validates the undo window.
    public func undoCodeHeal(id: String, repo: String) async throws -> AtlasCodeHealStepReceipt {
        struct UndoBody: Encodable { let repo: String }
        return try await post(AtlasRoute.codeHealUndo(id), body: UndoBody(repo: repo))
    }

    /// E5 · real weekly code numbers; notification remains opt-in.
    public func getCodeWeek(repo: String) async throws -> AtlasCodeWeek {
        try await get("\(AtlasRoute.codeWeek)\(atlasQueryString([("repo", .string(repo))]))")
    }
}
