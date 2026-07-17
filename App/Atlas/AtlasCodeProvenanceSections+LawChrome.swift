import SwiftUI
import AtlasCore

// Law citation chrome — peel de AtlasCodeProvenanceSections.

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    var lawCitationChrome: some View {
        if state == .violating, let ruleId, spokenLawCitation() != nil {
            VStack(alignment: .leading, spacing: 3) {
                Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                    .font(AtlasFont.serif(14, .semibold))
                    .foregroundStyle(AtlasCodePalette.alert)
                    .accessibilityHidden(true)
                if let ruleCanon = ruleCanon?.nonEmpty {
                    Text(ruleCanon)
                        .font(AtlasFont.mono(8.5))
                        .foregroundStyle(AtlasTheme.textTertiary.opacity(0.85))
                        .lineLimit(1)
                        .truncationMode(.head)
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AtlasCodePalette.alert.opacity(0.08))
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLawCitation() ?? "")
            .accessibilityIdentifier(A11yID.codeProvenanceLaw)
        }
    }
}
