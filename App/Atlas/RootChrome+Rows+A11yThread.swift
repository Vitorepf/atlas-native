import Foundation

// Thread spoken body — peel de RootChrome+Rows+A11yThread.
// Hint → RootChrome+Rows+A11yThreadHint.swift

extension RootChromeRowA11y {
    static func threadSpoken(
        title: String,
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> String {
        var parts = [title]
        parts.append(contentsOf: threadStatusParts(
            messageCount: messageCount,
            isRunning: isRunning,
            isNew: isNew,
            hasWorkspace: hasWorkspace
        ))
        return parts.joined(separator: ", ")
    }
}
