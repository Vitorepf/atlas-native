import ActivityKit
import AtlasCore
import Foundation
import UIKit
import UserNotifications

// Cycle 041 fuse → TurnPresence+Notifications.swift

#if canImport(ActivityKit)
#endif


@MainActor
extension TurnPresence {
    /// Propaga o contador novo para TODAS as activities vivas, preservando a
    /// fase e o timer de cada uma (lê o estado atual e só troca o contador).
    func broadcastCount() {
        #if canImport(ActivityKit)
        let count = activeCount
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities {
                let s = a.content.state
                guard !s.finished, s.activeSessions != max(1, count) else { continue }
                var next = s
                next.activeSessions = max(1, count)   // preserva fase, timer e pausa
                await a.update(.init(state: next, staleDate: nil))
            }
        }
        #endif
    }
}

#if canImport(ActivityKit)
#endif


@MainActor
extension TurnPresence {
    func endActivities(
        key: TraceID,
        state: AtlasTurnAttributes.ContentState,
        model: ConversationModel?,
        closed: Bool
    ) {
        #if canImport(ActivityKit)
        Task { @MainActor in
            for a in Activity<AtlasTurnAttributes>.activities where a.attributes.threadKey == key.rawValue {
                LiveActivityRemoteBridge.shared.end(
                    activityID: a.id,
                    model: model,
                    reason: closed ? "session_closed" : "completed"
                )
                await a.end(.init(state: state, staleDate: nil),
                            dismissalPolicy: .after(.now + 4))
            }
        }
        #endif
    }
}

#if canImport(ActivityKit)
#endif


@MainActor
extension TurnPresence {
    func finishActivity(_ entry: Entry, presence: AtlasExecutionPresence?,
                        phaseOverride: String? = nil) {
        #if canImport(ActivityKit)
        guard let key = entry.activityKey else { return }
        let progress = entry.model?.bubbles.last(where: { $0.traceId == key })?.executionProgress
        let state = contentState(entry, presence: presence, finished: true,
                                 phaseOverride: phaseOverride, progress: progress)
        endActivities(
            key: key,
            state: state,
            model: entry.model,
            closed: phaseOverride == "sessão encerrada"
        )
        entry.activityStarted = false
        entry.activityKey = nil
        #endif
    }

}

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
