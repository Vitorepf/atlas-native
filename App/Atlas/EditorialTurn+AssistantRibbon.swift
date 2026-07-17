import SwiftUI
import AtlasCore

// Execution ribbon — peel de EditorialTurn+Assistant.

extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionRibbon: some View {
        if bubble.streaming, bubble.hasLiveExecutionSurface {
            ExecutionRibbon(bubble: bubble, reduceMotion: reduceMotion, onStop: onStop)
        }
    }
}
