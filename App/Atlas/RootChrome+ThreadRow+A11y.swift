import SwiftUI
import AtlasCore

// Thread a11y — peel de RootChrome+ThreadRow.

extension ThreadRow {
    func threadA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                RootChromeRowA11y.threadSpoken(
                    title: thread.title,
                    messageCount: thread.messageCount,
                    isRunning: isRunning,
                    isNew: isNew,
                    hasWorkspace: workspaceTint != nil
                )
            )
            .accessibilityHint(RootChromeRowA11y.threadHint(isRunning: isRunning))
    }
}
