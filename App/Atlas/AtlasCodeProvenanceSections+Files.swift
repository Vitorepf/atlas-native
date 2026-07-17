import SwiftUI
import AtlasCore

// Arquivos e citação — peel de AtlasCodeProvenanceSections+Content.

extension AtlasCodeProvenanceSheet {
    func pullQuote(_ quote: String) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Rectangle()
                .fill(AtlasTheme.accent.opacity(0.55))
                .frame(width: 2)
            VStack(alignment: .leading, spacing: 5) {
                Text("\u{201C}\(quote)\u{201D}")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("sua frase")
                    .font(.system(size: 9))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel("sua frase: \(quote)")
    }

    @ViewBuilder
    func filesSection(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
        if !provenance.files.isEmpty {
            VStack(alignment: .leading, spacing: 9) {
                Text("ARQUIVOS")
                    .font(.system(size: 8.5, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier(A11yID.codeCommitFiles)

                VStack(spacing: 0) {
                    ForEach(Array(provenance.files.enumerated()), id: \.element.id) { index, file in
                        if index > 0 {
                            Divider().overlay(AtlasTheme.separator.opacity(0.5))
                        }
                        Button {
                            if !reduceMotion {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            }
                            whyTarget.wrappedValue = AtlasCodeProvenanceWhyTarget(path: file.path)
                        } label: {
                            AtlasCodeFileRow(file: file, accessibilityIdentifier: A11yID.whyFileRow(index))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(A11yID.whyFileRow(index))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
