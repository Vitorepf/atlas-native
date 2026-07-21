import SwiftUI
import AtlasCore

// WAVE-172 density peel — EditorialTurn user branch

// MARK: - User branch

extension EditorialTurn {
    @ViewBuilder
    var userTurn: some View {
        VStack(alignment: .leading, spacing: 8) {
            userQuote
            userEditResendButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension EditorialTurn {
    var userEditResendButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onEditResend()
        } label: {
            userEditResendLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(EditorialTurnJudgment.editResendLabel)
        .accessibilityHint("abre o compositor com este texto para um novo envio")
    }
}

extension EditorialTurn {
    var userEditResendLabel: some View {
        HStack(spacing: 5) {
            Image(systemName: "arrow.turn.down.right")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text("editar e reenviar")
                .atlasSans(11, .medium)
        }
        .foregroundStyle(AtlasTheme.textSecondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}

extension EditorialTurn {
    var userQuote: some View {
        Text("\"\(bubble.text)\"")
            .font(AtlasFont.serifItalic(18)).lineSpacing(8).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.leading, 16)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                    .accessibilityHidden(true)
            }
            .accessibilityLabel(EditorialTurnJudgment.spokenUserMessage(bubble.text))
    }
}
