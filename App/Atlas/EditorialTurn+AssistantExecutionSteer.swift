import SwiftUI
import AtlasCore

// Steer mapping — peel de EditorialTurn+AssistantExecutionCard.

extension EditorialTurn {
    var assistantSteerHandler: (() -> Void)? {
        let steerTrace = bubble.executionPresence?.isOngoing == true ? bubble.traceId : nil
        return steerTrace.map { trace in { onSteer(trace) } }
    }
}
