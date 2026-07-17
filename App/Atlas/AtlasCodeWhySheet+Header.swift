import SwiftUI
import AtlasCore

// Header Why — peel de AtlasCodeWhySheet.

extension AtlasCodeWhySheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("POR QUE ESTE ARQUIVO EXISTE")
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(file)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .truncationMode(.middle)
                .accessibilityHidden(true)
            if let why = model.why, why.truncated {
                Text("mostrando \(why.commits.count) de \(why.commitsTotal) · história truncada")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(whyHeaderSpokenLabel)
    }
}
