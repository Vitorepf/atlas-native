import SwiftUI
import UIKit

struct ComposerAttachmentRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Text(subtitle).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Spacer()
        }
        .padding(.horizontal, 24).padding(.vertical, 15)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(subtitle)")
    }
}
