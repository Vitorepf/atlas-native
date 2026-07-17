import SwiftUI

/// Empty/unavailable compartilhado por ArtifactSheet e ChangeReviewSheet.
/// Peel de ArtifactViewer+TraceEvidence.

struct TraceEvidenceUnavailable: View {
    let title: String
    let subtitle: String?
    let identifier: String
    let spoken: String
    var systemImage: String = "doc.text"

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(title)
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .accessibilityHidden(true)
            }
        }
        .padding(36)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
        .accessibilityIdentifier(identifier)
    }
}
