import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit

/// Trace wait + environment — peel de LiveActivityRemoteBridge.

extension LiveActivityRemoteBridge {
    func waitForTrace(_ model: ConversationModel) async -> TraceID? {
        for _ in 0..<30 {
            if let traceId = model.currentStreamingTraceId { return traceId }
            guard model.isSending else { return nil }
            try? await Task.sleep(for: .milliseconds(100))
        }
        return nil
    }

    static var environment: AtlasLiveActivityRegistrationInput.Environment {
        #if DEBUG
        .sandbox
        #else
        .production
        #endif
    }
}
#endif
