import SwiftUI
import AtlasCore

// Card de execução — peel de EditorialTurn+AssistantExecution.

extension EditorialTurn {
    @ViewBuilder
    func assistantExecutionCard(_ state: AtlasExecutionPresentationState) -> some View {
        let steerTrace = bubble.executionPresence?.isOngoing == true ? bubble.traceId : nil
        if ExecutionStateCard.shouldDisplay(state: state) {
            ExecutionStateCard(
                state: state,
                jobId: bubble.executionChoiceJobId,
                onChoose: onExecutionChoice,
                retryableJobId: bubble.retryableJobId,
                onRetry: onRetry,
                onSteer: steerTrace.map { trace in { onSteer(trace) } }
            )
        }
    }
}
