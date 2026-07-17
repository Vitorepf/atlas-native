import SwiftUI
import AtlasCore

// Row trailing — peel de LiveNowRow+Content+RowStack.

extension LiveNowRow {
    @ViewBuilder
    var rowContentTrailing: some View {
        Spacer(minLength: 0)
        rowChevron
    }
}
