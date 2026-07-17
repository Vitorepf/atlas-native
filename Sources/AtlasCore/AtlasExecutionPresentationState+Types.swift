import Foundation

/// Tipos aninhados — peel de AtlasExecutionPresentationState.

extension AtlasExecutionPresentationState {
    public enum Kind: String, Sendable, Equatable {
        case attentionRequired = "attention_required"
        case replanning
        case awaitingExternal = "awaiting_external"
        case recovering
        case failed
        case completed
    }

    public enum ActionStyle: String, Sendable, Equatable {
        case primary
        case secondary
        case destructive
    }

    public struct Action: Sendable, Equatable, Identifiable {
        public let id: String
        public let title: String
        public let style: ActionStyle
    }

    public struct Timer: Sendable, Equatable {
        public enum Timing: String, Sendable, Equatable {
            case running
            case paused
            case finished
        }

        public let elapsedActiveMilliseconds: Int
        public let timing: Timing
        public let runningSince: Date?
        public let pausedAt: Date?
        public let finishedAt: Date?
    }
}
