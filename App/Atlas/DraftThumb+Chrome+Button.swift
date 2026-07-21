import SwiftUI
import AtlasCore

// Remove button chrome — peel de DraftThumb+Chrome.

extension DraftThumb {
    @ViewBuilder
    var removeButtonChrome: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(18)
            .foregroundStyle(AtlasTheme.textPrimary, AtlasTheme.bgRecessed)
            .padding(8)
            .contentShape(Circle())
    }
}
