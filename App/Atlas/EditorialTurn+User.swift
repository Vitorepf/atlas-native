import SwiftUI
import AtlasCore

// User turn block — peel de EditorialTurn.

extension EditorialTurn {
    @ViewBuilder
    var userTurn: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(""\(bubble.text)"")
                .font(AtlasFont.serifItalic(18)).lineSpacing(8).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.leading, 16)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                }
            Button(action: onEditResend) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.system(size: 10, weight: .semibold))
                    Text("editar e reenviar")
                        .font(AtlasFont.mono(10))
                }
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("editar esta mensagem e reenviar como novo turno")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
