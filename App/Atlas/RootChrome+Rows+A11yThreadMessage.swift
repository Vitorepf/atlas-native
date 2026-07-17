import Foundation

// Message count fragments — peel de RootChrome+Rows+A11yThreadStatus.
// Running → RootChrome+Rows+A11yThreadRunning.swift
// Count → RootChrome+Rows+A11yThreadCount.swift

extension RootChromeRowA11y {
    static func threadMessageParts(messageCount: Int, isRunning: Bool) -> [String] {
        if isRunning { return spokenThreadRunning() }
        return spokenThreadMessageCount(messageCount)
    }
}
