import SwiftUI
import AtlasCore

// Refresh task — peel de AtlasCodeView+GraphListScroll.

extension AtlasCodeView {
    func graphListScrollRefresh() async {
        await model.load()
        await mirrorModel.refresh()
    }
}
