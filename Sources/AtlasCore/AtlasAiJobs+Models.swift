import Foundation

// Modelos de job e envelopes — peel de AtlasAiJobs.

public struct AtlasAiJobAttempt: Codable, Sendable, Identifiable {
    public let id: String
    public let aiJobId: String
    public let attemptNumber: Int
    public let workerId: String
    public let provider: String
    public let model: String?
    public let command: [JSONValue]?
    public let commandHash: String?
    public let promptHash: String
    public let responseHash: String?
    public let status: String
    public let exitCode: Int?
    public let durationMs: Int?
    public let outputText: String?
    public let stdoutExcerpt: String?
    public let stderrExcerpt: String?
    public let errorCode: String?
    public let errorMessage: String?
    public let startedAt: String
    public let finishedAt: String?
    public let metadata: JSONObject?
    public let createdAt: String
    public let updatedAt: String
}

public struct AtlasAiJob: Codable, Sendable, Identifiable {
    public let id: String
    public let traceId: String?
    public let clientId: String?
    public let kind: String
    public let status: String
    public let priority: Int
    public let agentSlug: String
    public let provider: String?
    public let model: String?
    public let inputText: String
    public let contextRefs: [JSONValue]?
    public let payload: JSONObject?
    public let atlasDecideExecution: AtlasAiExecutionState?
    public let atlasDecideStage: String?
    public let dependencyState: String?
    public let resultText: String?
    public let resultJson: JSONObject?
    public let errorCode: String?
    public let errorMessage: String?
    public let availableAt: String?
    public let reservedAt: String?
    public let startedAt: String?
    public let finishedAt: String?
    public let attempts: Int
    public let maxAttempts: Int
    public let timeoutSeconds: Int
    public let workerId: String?
    public let awaitingUserChoice: Bool?
    public let choiceOptions: [AtlasAiChoiceOption]?
    public let providerChoiceState: String?
    public let providerChoiceErrorCode: String?
    public let providerResetAt: String?
    public let resetHint: String?
    public let metadata: JSONObject?
    public let trace: AtlasAiTrace?
    public let attemptHistory: [AtlasAiJobAttempt]?
    public let createdAt: String
    public let updatedAt: String
}

public struct AiJobsResponse: Codable, Sendable { public let jobs: [AtlasAiJob] }
public struct AiJobResponse: Codable, Sendable { public let job: AtlasAiJob }
