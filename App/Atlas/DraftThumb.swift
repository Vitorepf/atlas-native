import SwiftUI
import UIKit
import AtlasCore

// Thumb de anexo do composer — peel de DraftStrip; spoken → DraftThumb+A11y.swift.

@MainActor
enum DraftThumbCache {
    static let store = NSCache<NSString, UIImage>()
    static func image(for draft: LocalDraft) -> UIImage? {
        if let hit = store.object(forKey: draft.id as NSString) { return hit }
        guard let data = draft.preview, let ui = UIImage(data: data) else { return nil }
        store.setObject(ui, forKey: draft.id as NSString); return ui
    }
}

struct DraftThumb: View {
    let draft: LocalDraft
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    private var failedMessage: String? {
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

    @ViewBuilder private var removeButton: some View {
        if draft.state != .subindo {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRemove(draft.id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AtlasTheme.textPrimary, AtlasTheme.bgRecessed)
                    .padding(8)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .offset(x: 12, y: -12)
            .accessibilityLabel(DraftThumbA11y.spokenRemove(draft))
            .accessibilityHint(DraftThumbA11y.removeHint)
            .accessibilityIdentifier(A11yID.draftRemove(draft.id))
        }
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

    @ViewBuilder private var stateVeil: some View {
        if draft.state == .subindo {
            ZStack { ProgressView().tint(.white) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.38))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.94)))
        } else if failedMessage != nil {
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 16))
                .foregroundStyle(AtlasTheme.domOperacional)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading).padding(6)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.9)))
        }
    }
}
