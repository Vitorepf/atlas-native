import SwiftUI
import AtlasCore

// Sheet content — peel de EffortSheet.

extension EffortSheet {
    @ViewBuilder
    var effortSheetContent: some View {
        effortFootnoteCopy
        effortRows
    }
}
