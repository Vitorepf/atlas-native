import Foundation
import AtlasCore

@MainActor
extension ConversationModel {
    func loadExecutionHistory() async {
        let refs = bubbles.compactMap { bubble -> (String, TraceID)? in
            guard bubble.role == "assistant", let traceId = bubble.traceId else { return nil }
            return (bubble.id, traceId)
        }
        let client = self.client
        var snapshots: [(String, AtlasAiTrace?)] = []
        var cursor = refs.startIndex
        while cursor < refs.endIndex {
            let end = refs.index(cursor, offsetBy: 6, limitedBy: refs.endIndex) ?? refs.endIndex
            let batch = refs[cursor..<end]
            let values = await withTaskGroup(of: (String, AtlasAiTrace?).self) { group in
                for (bubbleId, traceId) in batch {
                    group.addTask {
                        let trace = try? await client.getAiInteraction(traceId)
                        return (bubbleId, trace?.trace)
                    }
                }
                var values: [(String, AtlasAiTrace?)] = []
                for await value in group { values.append(value) }
                return values
            }
            snapshots.append(contentsOf: values)
            cursor = end
        }
        for (bubbleId, trace) in snapshots {
            if let trace { applyExecution(bubbleId, trace) }
        }
    }

    func applyExecution(
        _ id: String,
        _ trace: AtlasAiTrace,
        projectedStreamActivities: [AtlasAgentActivity]? = nil
    ) {
        let agents = (trace.jobs ?? []).map {
            ExecAgent(id: $0.id, agent: $0.agentSlug, provider: $0.provider, model: $0.model, status: $0.status)
        }
        let choiceJob = trace.jobs?.first { $0.turnStatus == .awaitingUserChoice }
        let failedJob = trace.jobs?.first { $0.turnStatus == .failed }
        update(id) {
            $0.agents = agents
            $0.decideStrategy = trace.atlasDecideExecution?.strategy
            $0.decideStage = trace.atlasDecideExecution?.atlasDecideStage
            $0.decisionSummary = trace.decisionSummary
            $0.qualitySummary = trace.qualitySummary
            $0.executionPlan = trace.executionPlan
            $0.diffStats = AtlasTraceGovernance.diffStats(from: trace.metadata)
            $0.planRevisions = AtlasTraceGovernance.planRevisions(from: trace.metadata)
            $0.executionProgress = trace.executionProgress
            $0.executionPresentationState = trace.executionPresentationState
            $0.executionChoiceJobId = choiceJob.map { JobID($0.id) }
            $0.retryableJobId = failedJob.map { JobID($0.id) }
            $0.reconnectNotice = nil
            let fromStream = projectedStreamActivities ?? atlasAgentTimeline(from: trace.streamEvents ?? [])
            let recovered = fromStream + trace.toolActivities
            $0.activities = atlasMergeAgentActivities(existing: $0.activities, incoming: recovered)
        }
    }
}
