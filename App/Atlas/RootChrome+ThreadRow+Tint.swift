import SwiftUI
import AtlasCore

// Tint leading do ThreadRow — peel de RootChrome+ThreadRow+Content.

extension ThreadRow {
    @ViewBuilder
    var rowWorkspaceTint: some View {
        if let workspaceTint {
            Rectangle()
                .fill(workspaceTint.opacity(0.85))
                .frame(width: 2)
                .padding(.vertical, 10)
                .accessibilityHidden(true)
        }
    }
}
