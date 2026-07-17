import SwiftUI
import AtlasCore

// Action/timer spoken fragments — peel de ExecutionStateCard+AwaitingFailed+Spoken.

extension ExecutionStateCard {
    var spokenActionFragment: String? {
        if !state.actions.isEmpty {
            return "\(state.actions.count) ação\(state.actions.count == 1 ? "" : "ões") disponíveis"
        }
        if showsRetryFallback {
            return "retomar disponível"
        }
        return nil
    }
}
