import SwiftUI
import AtlasCore

// MARK: - Seções da folha de proveniência (C23)
// Ask → AtlasCodeProvenanceSections+Ask.swift
// WhyTarget → AtlasCodeProvenanceWhyTarget.swift

extension AtlasCodeProvenanceSheet {
    /// A lei que sustenta a acusação — e o documento que a prova.
    @ViewBuilder
    var lawCitation: some View {
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
