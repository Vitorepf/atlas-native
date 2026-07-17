import SwiftUI
import AtlasCore

// Presentation chrome — peel de AutonomosSheetsModifier+SelfConstruction.

extension AutonomosSheetsModifier {
    func selfConstructionPresentation<V: View>(_ sheet: V) -> some View {
        sheet
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }
}
