import SwiftUI
import AtlasCore

// Transfer + detail + self-construction sheets — peel de AutonomosSheetsModifier.
// Self → AutonomosSheetsModifier+SelfConstruction.swift

extension AutonomosSheetsModifier {
    @ViewBuilder
    func detailSheets<Content: View>(on content: Content) -> some View {
        detailItemSheetsBind(on:
            transferSheetBind(on: content)
        )
    }
}
