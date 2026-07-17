import SwiftUI
import AtlasCore

// Arquivos — peel de AtlasCodeProvenanceSections+Content.
// Quote → AtlasCodeProvenanceSections+PullQuote.swift

extension AtlasCodeProvenanceSheet {
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
                            AtlasMotion.softImpact(reduceMotion: reduceMotion)
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
