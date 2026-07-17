import SwiftUI
import AtlasCore

// Caption — peel de WorkspaceThreadsSection.

extension WorkspaceThreadsSection {
    var caption: String {
        if area == .tudo {
            return "\(threads.count) conversa\(threads.count == 1 ? "" : "s")"
        }
        return "\(threads.count) em \(area.label)"
    }

    var spokenCaption: String {
        if area == .tudo {
            return "\(threads.count) conversa\(threads.count == 1 ? "" : "s") em \(screenTitle)"
        }
        return "\(threads.count) conversa\(threads.count == 1 ? "" : "s") em \(area.label), \(screenTitle)"
    }

    var captionHeader: some View {
        Text(caption.uppercased())
            .font(.system(.caption, weight: .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(spokenCaption)
            .accessibilityIdentifier(A11yID.workspaceThreadsCaption)
    }
}
