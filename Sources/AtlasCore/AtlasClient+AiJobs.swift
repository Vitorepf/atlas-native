import Foundation

// MARK: - Client methods (mirror de listAiJobs/getAiJob/retryAiJob/
// cancelAiJob/resumeAiJobChoice — atlasAi.ts §1662-1694)

public extension AtlasClient {
    func listAiJobs(
        status: String? = nil, provider: String? = nil, limit: Int? = nil
    ) async throws -> AiJobsResponse {
        let q = atlasQueryString([
            ("status", status.map { .string($0) }),
            ("provider", provider.map { .string($0) }),
            ("limit", limit.map { .int($0) }),
        ])
        return try await get("\(AtlasRoute.aiJobs)\(q)")
    }

    func getAiJob(_ id: String) async throws -> AiJobResponse {
        try await get(AtlasRoute.aiJob(id))
    }

    func retryAiJob(_ id: String) async throws -> AiJobResponse {
        try await post(AtlasRoute.aiJobRetry(id))
    }

    func cancelAiJob(_ id: String) async throws -> AiJobResponse {
        try await post(AtlasRoute.aiJobCancel(id))
    }

    func resumeAiJobChoice(_ jobId: String, optionId: String) async throws -> AiJobResponse {
        try await post(
            AtlasRoute.aiJobResumeChoice(jobId),
            body: ResumeChoiceInput(optionId: optionId)
        )
    }
}

/// POST body de `resumeAiJobChoice` — o encoder faz `.convertToSnakeCase`
/// (optionId -> option_id), casando o `{ option_id }` do .ts.
private struct ResumeChoiceInput: Encodable {
    let optionId: String
}
