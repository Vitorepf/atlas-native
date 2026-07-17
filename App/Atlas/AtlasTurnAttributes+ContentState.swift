import Foundation
#if canImport(ActivityKit)
import ActivityKit

/// ContentState payload — peel de AtlasActivityAttributes.

extension AtlasTurnAttributes {
    struct ContentState: Codable, Hashable {
        var phaseTitle: String
        var startedAt: Date
        var finished: Bool
        var activeSessions: Int
        var paused: Bool? = nil
        var pausedDisplay: String? = nil
        var progressCurrent: Int? = nil
        var progressTotal: Int? = nil
        var queuedCount: Int? = nil
    }
}
#endif
