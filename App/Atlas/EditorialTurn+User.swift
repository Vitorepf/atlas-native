import SwiftUI
import AtlasCore

// User turn block — peel de EditorialTurn.
// Quote → EditorialTurn+UserQuote.swift

extension EditorialTurn {
    @ViewBuilder
    var userTurn: some View {
        VStack(alignment: .leading, spacing: 8) {
            userQuote
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onEditResend()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.system(size: 10, weight: .semibold))
                        .accessibilityHidden(true)
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
            .accessibilityHint("abre o compositor com este texto para um novo envio")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
