import AtlasCore
import SwiftUI

// Cycle 038 fuse → AtlasCodeProvenanceSections.swift

// MARK: - Seções da folha de proveniência (C23)

extension AtlasCodeProvenanceSheet {
    /// A lei que sustenta a acusação — e o documento que a prova.
    @ViewBuilder
    var lawCitation: some View {
        lawCitationChrome
    }
}
