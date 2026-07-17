import SwiftUI
import AtlasCore

// Body chain — peel de AutonomosSheetsModifier.

extension AutonomosSheetsModifier {
    func autonomosSheetsBody(on content: Content) -> some View {
        detailSheets(on:
            nightlyStartSheet(on:
                controlSheets(on: content)
            )
        )
    }
}
