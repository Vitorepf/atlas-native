import SwiftUI
import AtlasCore

struct WorkspaceRow: View {
    let icon: String
    let name: String
    let count: Int?
    var detail: String?
    var badge: Bool = false
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(name).font(.system(.body)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                        .accessibilityHidden(true)
                    if let detail, !detail.isEmpty {
                        Text(detail)
                            .font(.system(.caption))
                            .foregroundStyle(AtlasTheme.alert)
                            .lineLimit(1)
                            .accessibilityHidden(true)
                    }
                }
                Spacer(minLength: 8)
                rowTrailing
            }
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(RootChromeRowA11y.workspaceSpoken(name: name, count: count, detail: detail, badge: badge))
        .accessibilityHint("abre \(name)")
    }
}
