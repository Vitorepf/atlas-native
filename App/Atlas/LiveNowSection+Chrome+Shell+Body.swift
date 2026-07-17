import SwiftUI
import AtlasCore

// Section body — peel de LiveNowSection+Chrome+Shell.

extension LiveNowSection {
    var liveNowSectionBody: some View {
        VStack(alignment: .leading, spacing: isHub ? 0 : 12) {
            header
            liveNowRows
        }
    }
}
