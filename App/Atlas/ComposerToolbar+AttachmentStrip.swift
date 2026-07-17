import SwiftUI
import AtlasCore

// Faixa de anexos + progresso de upload — peel de ComposerToolbar.

struct AttachmentStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let uploadPercent: Double?
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        Group {
            if !drafts.isEmpty {
                DraftStrip(drafts: drafts, reduceMotion: reduceMotion,
                           onRemove: onRemove, onFailedTap: onFailedTap)
            }
            if let p = uploadPercent {
                HStack(spacing: 10) {
                    ProgressView(value: p).tint(AtlasTheme.accent)
                    Text("\(Int(p * 100))%")
                        .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("enviando anexos, \(Int(p * 100)) por cento")
            }
        }
    }
}
