import SwiftUI
import AtlasCore

// Execution state block — peel de EditorialTurn+Assistant.

extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionBlock: some View {
        if let state = bubble.executionPresentationState {
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
}
