import SwiftUI
import UIKit
import AtlasCore

// Thumb de anexo do composer — peel de DraftStrip.

@MainActor
enum DraftThumbCache {
    static let store = NSCache<NSString, UIImage>()
    static func image(for draft: LocalDraft) -> UIImage? {
        if let hit = store.object(forKey: draft.id as NSString) { return hit }
        guard let data = draft.preview, let ui = UIImage(data: data) else { return nil }
        store.setObject(ui, forKey: draft.id as NSString)
        return ui
    }
}

struct DraftThumb: View {
    let draft: LocalDraft
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    private var failedMessage: String? {
        if case .falhou(let m) = draft.state { return m }
        return nil
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            thumb
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(failedMessage != nil ? AtlasTheme.domOperacional.opacity(0.8) : AtlasTheme.separator,
                            lineWidth: failedMessage != nil ? 1.5 : 1))
                .overlay { stateVeil }
                .onTapGesture { if let m = failedMessage { onFailedTap("falhou: \(m)") } }

            if draft.state != .subindo {
                Button { onRemove(draft.id) } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AtlasTheme.textPrimary, AtlasTheme.bgRecessed)
                        .padding(8)          // alvo ~44pt sem crescer o ícone
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .offset(x: 12, y: -12)
                .accessibilityLabel("remover \(draft.fileName)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(a11yLabel)
    }

    @ViewBuilder private var thumb: some View {
        if draft.kind == .image, let ui = DraftThumbCache.image(for: draft) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            VStack(spacing: 4) {
                Image(systemName: "doc.fill").font(.system(size: 20)).foregroundStyle(AtlasTheme.textSecondary)
                Text((draft.fileName as NSString).pathExtension.uppercased())
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AtlasTheme.surfaceHi)
        }
    }

    @ViewBuilder private var stateVeil: some View {
        if draft.state == .subindo {
            ZStack { ProgressView().tint(.white) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.38))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else if failedMessage != nil {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AtlasTheme.domOperacional)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(6)
        }
    }

    private var a11yLabel: String {
        let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
        let state: String
        switch draft.state {
        case .pronto: state = "pronto para enviar"
        case .subindo: state = "enviando"
        case .falhou: state = "falhou, toque para ver o motivo"
        }
        return "anexo \(draft.fileName), \(mb) megabytes, \(state)"
    }
}
