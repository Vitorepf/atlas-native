import Foundation
import UIKit
import UserNotifications
import AtlasCore

// Notificação local quando uma resposta conclui com o app fora da tela —
// peel de TurnPresence (régua anti-inchaço). Spoken → +Notifications+A11y.

@MainActor
extension TurnPresence {
    /// Avisa SÓ pela fase pública terminal — nunca por isSending virar falso.
    func notifyIfAway(_ entry: Entry, model: ConversationModel,
                      finalPresence: AtlasExecutionPresence?, traceId: TraceID?) {
        guard UIApplication.shared.applicationState != .active else { return }
        guard let presence = finalPresence,
              TurnPresenceNotificationA11y.isTerminal(presence) else { return }

        let bubble = traceId.flatMap { key in
            model.bubbles.last(where: { $0.traceId == key })
        }
        let content = UNMutableNotificationContent()
        content.title = TurnPresenceNotificationA11y.title(from: presence)
        content.subtitle = Self.lockScreenText(entry.threadTitle, limit: 48)
        if let body = TurnPresenceNotificationA11y.body(
            presence: presence,
            assistantExcerpt: bubble?.text,
            presentationDetail: bubble?.executionPresentationState?.detail
        ) {
            content.body = body
        }
        if !UIAccessibility.isReduceMotionEnabled { content.sound = .default }
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }

}
