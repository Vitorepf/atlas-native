import SwiftUI
import AtlasCore

// Law citation body — peel de AtlasCodeProvenanceSections+LawChrome.
// Pad/chrome → AtlasCodeProvenanceSections+LawChromePad.swift

extension AtlasCodeProvenanceSheet {
    @ViewBuilder
    func lawCitationBody(ruleId: String) -> some View {
        lawCitationChrome(
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
        )
    }
}
