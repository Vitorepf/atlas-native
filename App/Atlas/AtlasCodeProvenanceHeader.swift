import AtlasCore
import SwiftUI

// Cycle 041 fuse → AtlasCodeProvenanceHeader.swift

// MARK: - Cabeçalho da folha de proveniência (C23)

extension AtlasCodeProvenanceSheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            headerStateKicker
            headerTitle
            headerDatelineBlock
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isHeader)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
