import SwiftUI
import AtlasCore

// Upload percent row — peel de ComposerToolbar+AttachmentStrip.

extension AttachmentStrip {
    @ViewBuilder
    var uploadProgressRow: some View {
        if let p = uploadPercent {
            HStack(spacing: 10) {
                ProgressView(value: p).tint(AtlasTheme.accent)
                Text("\(Int(p * 100))%")
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("enviando anexos, \(Int(p * 100)) por cento")
        }
    }

    var isVisible: Bool { !drafts.isEmpty || uploadPercent != nil }
}
