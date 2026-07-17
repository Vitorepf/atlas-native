import SwiftUI
import AtlasCore

// Provenance presentation — peel de AtlasCodeView+Sheets+ProvenanceBind.

extension AtlasCodeSheetsModifier {
    func provenanceSheetPresent<Content: View>(_ sheet: Content) -> some View {
        sheet
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
    }
}
