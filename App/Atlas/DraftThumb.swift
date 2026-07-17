import SwiftUI
import UIKit
import AtlasCore

// Thumb de anexo do composer — peel de DraftStrip.
// Cache → +Cache · remove/veil → +Chrome · spoken → +A11y.
struct DraftThumb: View {
    let draft: LocalDraft
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var failedMessage: String? {
        if case .falhou(let m) = draft.state { return m }
        return nil
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            thumbContent
            removeButton
        }
    }

    private var thumbContent: some View {
        thumb
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(failedMessage != nil ? AtlasTheme.domOperacional.opacity(0.8) : AtlasTheme.separator,
                        lineWidth: failedMessage != nil ? 1.5 : 1))
            .overlay { stateVeil }
            .onTapGesture { if let m = failedMessage { onFailedTap("falhou: \(m)") } }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(DraftThumbA11y.spokenThumb(draft))
            .accessibilityValue(failedMessage.map { DraftThumbA11y.spokenFailedValue($0) } ?? "")
            .accessibilityHint(failedMessage != nil ? DraftThumbA11y.failedHint : "")
            .accessibilityAddTraits(failedMessage != nil ? .isButton : [])
            .accessibilityIdentifier(A11yID.draft(draft.id))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: draft.state)
    }

    @ViewBuilder private var thumb: some View {
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
