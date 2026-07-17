import Foundation
import UIKit
import UserNotifications
import AtlasCore

// Notificação local quando uma resposta conclui com o app fora da tela —
// peel de TurnPresence (régua anti-inchaço).

@MainActor
extension TurnPresence {
    /// Avisa SÓ pela fase pública terminal — nunca por isSending virar falso.
    func notifyIfAway(_ entry: Entry, model: ConversationModel,
                      finalPresence: AtlasExecutionPresence?) {
        guard UIApplication.shared.applicationState != .active else { return }
        let failed = finalPresence?.phaseTitle == "Falhou"
        let excerpt = model.bubbles.last(where: { $0.role == "assistant" })?.text ?? ""
        let content = UNMutableNotificationContent()
        content.title = failed ? "O turno falhou" : "Atlas respondeu"
        content.subtitle = Self.lockScreenText(entry.threadTitle, limit: 48)
        // O texto SEM a sintaxe: este é o mesmo campo que a tela entrega ao
        // parser markdown, e ia cru para a Lock Screen — o operador longe do app
        // lia `**pronto**` e `## Resposta` em vez da resposta.
        content.body = failed ? "Toque para ver o motivo e retomar."
                              : Self.lockScreenText(AtlasMarkdown.plainText(excerpt), limit: 140)
        content.sound = .default
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }

    /// Pede permissão no PRIMEIRO turno concluído (momento de valor real),
    /// nunca no launch — UX de permissão digna.
    func requestPermissionOnce() async {
        guard !askedPermission else { return }
        askedPermission = true
        // `await` de propósito: sem esperar o veredito, a notificação sai antes
        // de existir permissão e o iOS a descarta calada.
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    static func lockScreenText(_ value: String, limit: Int) -> String {
        let collapsed = value
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard collapsed.count > limit else { return collapsed }
        return String(collapsed.prefix(max(0, limit - 1))) + "…"
    }
}
