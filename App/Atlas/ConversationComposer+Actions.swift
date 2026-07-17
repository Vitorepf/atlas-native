import SwiftUI
import PhotosUI
import AtlasCore

// Ações do composer — peel de ConversationComposer (régua anti-inchaço).
// Steer → ConversationComposer+Steer.swift

extension ConversationComposer {
    @ViewBuilder var composerSurface: some View {
        if expanded || liveBubble != nil {
            // Com execução viva o card cresce em cartão (capsule de 2 linhas
            // deformaria); a borda dourada continua reservada ao foco.
            RoundedRectangle(cornerRadius: 26, style: .continuous).fill(AtlasTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(expanded ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
        } else {
            Capsule(style: .continuous).fill(AtlasTheme.surface)
                .overlay(Capsule(style: .continuous).stroke(AtlasTheme.separator, lineWidth: 1))
        }
    }

    func dismissKeyboard() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        if reduceMotion {
            focused.wrappedValue = false
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) { focused.wrappedValue = false }
        }
    }

    func send() {
        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
        let text = model.draftText
        let effort = model.effort
        Task { await model.send(text, effort: effort) }
    }

    var queueChipLabel: String {
        let n = model.queuedMessages.count
        return n == 1 ? "Fila · 1" : "Fila · \(n)"
    }

    var queueAccessibilityLabel: String {
        let n = model.queuedMessages.count
        return n == 1
            ? "1 mensagem na fila durante a execução"
            : "\(n) mensagens na fila durante a execução"
    }
}
