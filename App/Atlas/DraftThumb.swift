import AtlasCore
import Foundation
import SwiftUI
import UIKit

// Cycle 043 fuse → DraftThumb.swift

struct DraftThumb: View {
    let draft: LocalDraft
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            thumbContent
            removeButton
        }
    }
}

/// Tamanho só quando bytes publicados; tipo imagem/arquivo honesto.

enum DraftThumbA11y {
    static func spokenRemove(_ draft: LocalDraft) -> String {
        DraftThumbA11yHints.spokenRemove(draft)
    }

    static let removeHint = DraftThumbA11yHints.removeHint
    static let failedHint = DraftThumbA11yHints.failedHint

    static func spokenFailedValue(_ message: String) -> String {
        DraftThumbA11yHints.spokenFailedValue(message)
    }
}

enum DraftThumbA11yHints {
    static let removeHint = "remove este anexo antes do envio"
    static let failedHint = "toque para ver o erro completo no aviso"

    static func spokenFailedValue(_ message: String) -> String {
        message.isEmpty ? "erro no envio" : message
    }

    static func spokenRemove(_ draft: LocalDraft) -> String {
        "remover anexo \(draft.fileName)"
    }
}

@MainActor
enum DraftThumbCache {
    static let store = NSCache<NSString, UIImage>()
    static func image(for draft: LocalDraft) -> UIImage? {
        if let hit = store.object(forKey: draft.id as NSString) { return hit }
        guard let data = draft.preview, let ui = UIImage(data: data) else { return nil }
        store.setObject(ui, forKey: draft.id as NSString); return ui
    }
}

extension DraftThumb {
    func removeButtonA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(DraftThumbA11y.spokenRemove(draft))
            .accessibilityHint(DraftThumbA11y.removeHint)
            .accessibilityIdentifier(A11yID.draftRemove(draft.id))
    }
}

extension DraftThumb {
    @ViewBuilder
    var removeButtonChrome: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(18)
            .foregroundStyle(AtlasTheme.textPrimary, AtlasTheme.bgRecessed)
            .frame(width: 44, height: 44)
            .contentShape(Circle())
    }
}

extension DraftThumb {
    @ViewBuilder var removeButton: some View {
        if draft.state != .subindo {
            removeButtonA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onRemove(draft.id)
                } label: {
                    removeButtonChrome
                }
                .buttonStyle(.plain)
                .offset(x: 12, y: -12)
            )
        }
    }
}

extension DraftThumb {
    @ViewBuilder var stateVeil: some View {
        if draft.state == .subindo {
            ZStack { ProgressView().tint(.white) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.38))
                .clipShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.94)))
        } else if failedMessage != nil {
            Image(systemName: "exclamationmark.triangle.fill").atlasSans(16)
                .foregroundStyle(AtlasTheme.domOperacional)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading).padding(6)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.9)))
        }
    }
}

extension DraftThumb {
    var failedMessage: String? {
        if case .falhou(let m) = draft.state { return m }
        return nil
    }
}

extension DraftThumb {
    @ViewBuilder var thumb: some View {
        if draft.kind == .image, let ui = DraftThumbCache.image(for: draft) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            VStack(spacing: 4) {
                Image(systemName: "doc.fill").atlasSans(20).foregroundStyle(AtlasTheme.textSecondary)
                Text((draft.fileName as NSString).pathExtension.uppercased())
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(AtlasTheme.surfaceHi)
        }
    }
}

extension DraftThumbA11y {
    static func spokenThumbSizeParts(_ draft: LocalDraft) -> [String] {
        guard draft.bytes > 0 else { return [] }
        let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
        return ["\(mb) megabytes"]
    }
}

extension DraftThumbA11y {
    static func spokenThumbReadyParts(_ draft: LocalDraft) -> [String]? {
        switch draft.state {
        case .pronto: return ["pronto para enviar"]
        case .subindo: return ["enviando"]
        default: return nil
        }
    }
}

extension DraftThumbA11y {
    static func spokenThumbStateParts(_ draft: LocalDraft) -> [String] {
        if let ready = spokenThumbReadyParts(draft) { return ready }
        if case .falhou(let message) = draft.state {
            var parts = ["falhou"]
            if !message.isEmpty { parts.append(message) }
            return parts
        }
        return []
    }
}

extension DraftThumbA11y {
    static func spokenThumb(_ draft: LocalDraft) -> String {
        let noun = draft.kind == .image ? "imagem" : "arquivo"
        var parts = ["anexo \(noun) \(draft.fileName)"]
        parts.append(contentsOf: spokenThumbSizeParts(draft))
        parts.append(contentsOf: spokenThumbStateParts(draft))
        return parts.joined(separator: ", ")
    }
}

extension DraftThumb {
    func thumbContentA11y<V: View>(_ framed: V) -> some View {
        framed
            .overlay { stateVeil }
            .onTapGesture {
                if let m = failedMessage {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onFailedTap("falhou: \(m)")
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(DraftThumbA11y.spokenThumb(draft))
            .accessibilityValue(failedMessage.map { DraftThumbA11y.spokenFailedValue($0) } ?? "")
            .accessibilityHint(failedMessage != nil ? DraftThumbA11y.failedHint : "")
            .accessibilityAddTraits(failedMessage != nil ? .isButton : [])
            .accessibilityIdentifier(A11yID.draft(draft.id))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: draft.state)
    }
}

extension DraftThumb {
    var thumbFrame: some View {
        thumb
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .stroke(
                        failedMessage != nil
                            ? AtlasTheme.domOperacional.opacity(0.8)
                            : AtlasTheme.separator,
                        lineWidth: failedMessage != nil ? 1.5 : 1
                    )
            )
    }
}

extension DraftThumb {
    var thumbContent: some View {
        thumbContentA11y(thumbFrame)
    }
}
