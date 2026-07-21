import AtlasCore
import Foundation
import UIKit
import UserNotifications

// Cycle 038 fuse → TurnPresence+Notifications.swift

@MainActor
enum TurnPresenceNotificationA11y {
    static func isTerminal(_ presence: AtlasExecutionPresence) -> Bool {
        TurnPresenceNotificationA11yTerminal.isTerminal(presence)
    }

    static func title(from presence: AtlasExecutionPresence) -> String {
        TurnPresenceNotificationA11yTerminal.title(from: presence)
    }

    /// Corpo só com dado real: excerpt da bolha do trace ou `detail` do ledger.
    static func body(
        presence: AtlasExecutionPresence,
        assistantExcerpt: String?,
        presentationDetail: String?
    ) -> String? {
        TurnPresenceNotificationA11yBody.body(
            presence: presence,
            assistantExcerpt: assistantExcerpt,
            presentationDetail: presentationDetail
        )
    }

    static func spoken(title: String, subtitle: String, body: String?) -> String {
        TurnPresenceNotificationA11ySpoken.spoken(title: title, subtitle: subtitle, body: body)
    }
}

@MainActor
enum TurnPresenceNotificationA11yBody {
    /// Corpo só com dado real: excerpt da bolha do trace ou `detail` do ledger.
    static func body(
        presence: AtlasExecutionPresence,
        assistantExcerpt: String?,
        presentationDetail: String?
    ) -> String? {
        switch presence.phaseTitle {
        case "Falhou":
            guard let detail = presentationDetail?
                .trimmingCharacters(in: .whitespacesAndNewlines), !detail.isEmpty else { return nil }
            return TurnPresence.lockScreenText(detail, limit: 140)
        case "Concluído":
            guard let excerpt = assistantExcerpt?
                .trimmingCharacters(in: .whitespacesAndNewlines), !excerpt.isEmpty else { return nil }
            return TurnPresence.lockScreenText(AtlasMarkdown.plainText(excerpt), limit: 140)
        default:
            return nil
        }
    }
}

enum TurnPresenceNotificationA11ySpoken {
    static func spoken(title: String, subtitle: String, body: String?) -> String {
        guard let body, !body.isEmpty else { return "\(title), \(subtitle)" }
        return "\(title), \(subtitle). \(body)"
    }
}

enum TurnPresenceNotificationA11yTerminal {
    /// Só fases terminais publicadas pelo contrato de presença.
    static func isTerminal(_ presence: AtlasExecutionPresence) -> Bool {
        presence.timing == .finished
            && (presence.phaseTitle == "Concluído" || presence.phaseTitle == "Falhou")
    }

    static func title(from presence: AtlasExecutionPresence) -> String {
        presence.phaseTitle
    }
}

@MainActor
extension TurnPresence {
    func notifyIfAway(_ entry: Entry, model: ConversationModel,
                      finalPresence: AtlasExecutionPresence?, traceId: TraceID?) {
        guard UIApplication.shared.applicationState != .active else { return }
        guard let presence = finalPresence,
              TurnPresenceNotificationA11y.isTerminal(presence) else { return }

        let bubble = traceId.flatMap { key in
            model.bubbles.last(where: { $0.traceId == key })
        }
        let content = buildAwayNotificationContent(
            entry: entry,
            presence: presence,
            bubble: bubble
        )
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }
}

@MainActor
extension TurnPresence {
    func buildAwayNotificationContent(
        entry: Entry,
        presence: AtlasExecutionPresence,
        bubble: ChatBubble?
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = TurnPresenceNotificationA11yTerminal.title(from: presence)
        content.subtitle = Self.lockScreenText(entry.threadTitle, limit: 48)
        if let body = TurnPresenceNotificationA11yBody.body(
            presence: presence,
            assistantExcerpt: bubble?.text,
            presentationDetail: bubble?.executionPresentationState?.detail
        ) {
            content.body = body
        }
        if !UIAccessibility.isReduceMotionEnabled { content.sound = .default }
        return content
    }
}

@MainActor
extension TurnPresence {
    static func lockScreenText(_ value: String, limit: Int) -> String {
        let collapsed = value
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard collapsed.count > limit else { return collapsed }
        return String(collapsed.prefix(max(0, limit - 1))) + "…"
    }
}

@MainActor
extension TurnPresence {
    /// Pede permissão no PRIMEIRO turno concluído (momento de valor real),
    /// nunca no launch — UX de permissão digna.
    func requestPermissionOnce() async {
        guard !askedPermission else { return }
        askedPermission = true
        // `await` de propósito: sem esperar o veredito, a notificação sai antes
        // de existir permissão e o iOS a descarta calada.
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }
}

// Notificação local quando uma resposta conclui com o app fora da tela.
