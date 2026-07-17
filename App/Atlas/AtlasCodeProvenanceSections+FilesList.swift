import SwiftUI
import AtlasCore

// File list — peel de AtlasCodeProvenanceSections+Files.

extension AtlasCodeProvenanceSheet {
    func provenanceFilesList(
        _ provenance: AtlasCodeProvenance,
        whyTarget: Binding<AtlasCodeProvenanceWhyTarget?>
    ) -> some View {
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
