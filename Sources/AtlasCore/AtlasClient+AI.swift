import Foundation

extension AtlasClient {
    // MARK: - Atlas AI: o loop de conversa (mirror de atlasAi.ts)

    public func listAiThreads(
        status: String? = nil, surface: String? = nil, workspace: String? = nil,
        includeMessages: Bool? = nil, light: Bool? = nil, limit: Int? = nil
    ) async throws -> AiThreadsResponse {
        let q = atlasQueryString([
            ("status", status.map { .string($0) }),
            ("surface", surface.map { .string($0) }),
            ("workspace", workspace.map { .string($0) }),
            ("include_messages", includeMessages.map { .bool($0) }),
            ("light", light.map { .bool($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("\(AtlasRoute.aiThreads)\(q)")
    }

    public func getAiThread(_ id: String) async throws -> AiThreadResponse {
        try await get(AtlasRoute.aiThread(id))
    }

    public func updateAiThread(_ id: String, patch: [String: JSONValue]) async throws -> AiThreadResponse {
        try await self.patch(AtlasRoute.aiThread(id), body: patch)
    }

    public func deleteAiThread(_ id: String) async throws -> JSONValue {
        try await delete(AtlasRoute.aiThread(id))
    }

    public func listAiInteractions(
        threadId: String? = nil, status: String? = nil, agent: String? = nil,
        clientId: String? = nil, limit: Int? = nil
    ) async throws -> AiInteractionsResponse {
        let q = atlasQueryString([
            ("thread_id", threadId.map { .string($0) }),
            ("status", status.map { .string($0) }),
            ("agent", agent.map { .string($0) }),
            ("client_id", clientId.map { .string($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("\(AtlasRoute.aiInteractions)\(q)")
    }

    public func getAiInteraction(_ id: TraceID) async throws -> AiTraceResponse {
        try await get(AtlasRoute.aiInteraction(id.rawValue))
    }

    /// Caminho JSON de `createAiInteraction` (sem anexos). Upload em chunks
    /// precisa do FileSystem do device — porta com a camada de anexos.
    public func createAiInteraction(_ input: CreateAiInteractionInput) async throws -> AiTraceResponse {
        // O create é síncrono e pesado (monta contexto semântico; com DOCUMENTO
        // ainda extrai PDF/OCR antes do 202): 15s default estoura o -1001.
        // 90s sem documentos, 120s com.
        let hasDocuments = !(input.uploadedDocuments ?? []).isEmpty
        return try await post(AtlasRoute.aiInteractions, body: input, timeout: hasDocuments ? 120 : 90)
    }
}
