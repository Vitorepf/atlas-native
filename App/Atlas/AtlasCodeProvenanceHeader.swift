import SwiftUI
import AtlasCore

// MARK: - Cabeçalho da folha de proveniência (C23)
// Meta → AtlasCodeProvenanceHeader+Meta.swift · Dateline → +Dateline.swift
// Title → AtlasCodeProvenanceHeader+Title.swift
// State → AtlasCodeProvenanceHeader+StateKicker.swift

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
