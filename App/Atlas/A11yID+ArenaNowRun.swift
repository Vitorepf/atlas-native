import Foundation

// Arena now run A11yID — peel de A11yID+Arena.

extension A11yID {
    static let arenaNowRunPrefix = "arena-now-run-"
    static func arenaNowRun(_ runId: String) -> String { arenaNowRunPrefix + runId }
}
