import SwiftUI
import AtlasCore

// Meta + timeline rail — peel de AtlasCodeWhySheet+Rows.

extension AtlasCodeWhySheet {
    func whyRowRail(isLast: Bool) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(AtlasTheme.accent)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            if !isLast {
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.35))
                    .frame(width: 1)
                    .frame(minHeight: 56)
                    .accessibilityHidden(true)
            }
        }
        .padding(.top, 7)
        .accessibilityHidden(true)
    }

    func meta(for commit: AtlasCodeWhy.Commit) -> String {
        var parts = [commit.agentLabel]
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        if let obra = commit.provenance?.obra, !obra.isEmpty { parts.append(obra) }
        return parts.joined(separator: " · ")
    }
}
