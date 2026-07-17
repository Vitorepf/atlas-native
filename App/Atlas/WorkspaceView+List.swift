import SwiftUI
import AtlasCore

// Peel anti-inchaço — lista e links honestos do WorkspaceView (só threads reais).
// Link → WorkspaceView+ThreadLink.swift

struct WorkspaceThreadsSection: View {
    let threads: [AtlasAiThread]
    let area: AtlasArea
    let screenTitle: String
    let reduceMotion: Bool

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

    var body: some View {
        Group {
            Text(caption.uppercased())
                .font(.system(.caption, weight: .semibold)).tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(spokenCaption)
                .accessibilityIdentifier(A11yID.workspaceThreadsCaption)
            ForEach(threads) { t in
                WorkspaceThreadLink(thread: t, reduceMotion: reduceMotion)
                if t.id != threads.last?.id {
                    Divider().overlay(AtlasTheme.separator)
                        .padding(.leading, AtlasTheme.Space.screen + 36)
                }
            }
        }
    }
}
