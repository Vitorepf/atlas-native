import SwiftUI
import UIKit
import AtlasCore

// Imagem/doc do thumb — peel de DraftThumb.

extension DraftThumb {
    @ViewBuilder var thumb: some View {
        if draft.kind == .image, let ui = DraftThumbCache.image(for: draft) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            VStack(spacing: 4) {
                Image(systemName: "doc.fill").font(.system(size: 20)).foregroundStyle(AtlasTheme.textSecondary)
                Text((draft.fileName as NSString).pathExtension.uppercased())
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(AtlasTheme.surfaceHi)
        }
    }
}
