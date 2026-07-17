import SwiftUI
import AtlasCore

// Mirror card tail — peel de AtlasCodeView+GraphListTail.

extension AtlasCodeView {
    @ViewBuilder
    var graphListMirrorCard: some View {
        if let mirror = mirrorModel.response {
            AtlasCodeMirrorCard(response: mirror)
                .padding(.top, 22)
        }
    }
}
