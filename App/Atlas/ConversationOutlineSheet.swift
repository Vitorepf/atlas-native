import SwiftUI
import AtlasCore

// Sheet body branch — peel de ConversationOutlineSheet.

extension ConversationOutlineSheet {
    @ViewBuilder
    var outlineSheetContent: some View {
        if bubbles.isEmpty {
            outlineEmpty
        } else {
            outlineRowList
        }
    }
}
